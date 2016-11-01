require 'spec_helper'

describe User do
  describe 'validations' do
    it 'must have a first name' do
      expect { FactoryGirl.create(:user, first_name: 'Carlos') }.not_to raise_error

      expect { FactoryGirl.create(:user, first_name: nil) }.to raise_error ActiveRecord::RecordInvalid, /First name can't be blank/
    end

    it 'must have a last name' do
      expect { FactoryGirl.create(:user, last_name: 'Perez') }.not_to raise_error

      expect { FactoryGirl.create(:user, last_name: nil) }.to raise_error ActiveRecord::RecordInvalid, /Last name can't be blank/
    end

    it 'must have a password wit 8 characters at least' do
      expect { FactoryGirl.create(:user, password: '12345678') }.not_to raise_error

      expect { FactoryGirl.create(:user, password: nil) }.to raise_error ActiveRecord::RecordInvalid, /Password can't be blank/
      expect { FactoryGirl.create(:user, password: '1234567') }.to raise_error ActiveRecord::RecordInvalid, /Password is too short/
    end

    it 'must have a unique email' do
      expect { FactoryGirl.create(:user, email: 'asd@sdf.com') }.not_to raise_error

      expect { FactoryGirl.create(:user, email: nil) }.to raise_error ActiveRecord::RecordInvalid, /Email can't be blank/
      expect { FactoryGirl.create(:user, email: 'asd@sdf.com') }.to raise_error ActiveRecord::RecordInvalid, /Email has already been taken/
    end

    it 'must have a unique nickname' do
      expect { FactoryGirl.create(:user, nickname: 'nickname') }.not_to raise_error

      expect { FactoryGirl.create(:user, nickname: nil) }.to raise_error ActiveRecord::RecordInvalid, /Nickname can't be blank/
      expect { FactoryGirl.create(:user, nickname: 'nickname') }.to raise_error ActiveRecord::RecordInvalid, /Nickname has already been taken/
    end

    it 'could have been invited by another user' do
      existing_user = FactoryGirl.create(:user)

      invited_user = FactoryGirl.create(:user, invited_by: existing_user)

      expect(invited_user).to be_valid
      expect(invited_user.invited_by).to eq existing_user
      expect { existing_user.update_attributes!(invited_by: existing_user) }.to raise_error ActiveRecord::RecordInvalid, /Can not invite itself/
    end
  end

  describe '#ranking_on_tournament' do
    let(:user) { FactoryGirl.create(:user) }
    let(:tournament_a) { FactoryGirl.create(:tournament, name: 'A') }

    let!(:ranking_a) { FactoryGirl.create(:ranking, user: user, tournament: tournament_a) }
    let!(:another_ranking_a) { FactoryGirl.create(:ranking, tournament: tournament_a) }
    let!(:ranking_b) { FactoryGirl.create(:ranking, user: user, tournament: FactoryGirl.create(:tournament, name: 'B')) }

    it 'returns the ranking of the user for the given tournament' do
      expect(user.ranking_on_tournament tournament_a).to eq ranking_a
    end
  end

  describe '#earned_coins_in_table' do
    let(:user) { FactoryGirl.create(:user) }
    let(:table) { FactoryGirl.create(:table) }

    context 'when the given user earned some coins' do
      let!(:user_prize) { FactoryGirl.create(:user_prize, table: table, user: user, coins: 10) }

      it 'returns the coins that the user earned in that table' do
        earned_coins = user.earned_coins_in_table(table) { 0 }

        expect(earned_coins).to eq user_prize.coins
      end
    end

    context 'when the given user did not earn coins' do
      it 'evaluates the given block' do
        earned_coins = user.earned_coins_in_table(table) { 0 }

        expect(earned_coins).to eq 0
      end
    end
  end

  describe '#bet_coins_in_table' do
    let(:user) { FactoryGirl.create(:user) }
    let(:table) { FactoryGirl.create(:table) }

    context 'when the given user played in that table' do
      let!(:play) { FactoryGirl.create(:play, user: user, table: table, bet_coins: 10) }

      it 'returns the coins that the user bet in that table' do
        earned_coins = user.bet_coins_in_table(table) { 0 }

        expect(earned_coins).to eq play.bet_coins
      end
    end

    context 'when the given user did not play in that table' do
      it 'evaluates the given block' do
        bet_coins = user.bet_coins_in_table(table) { 0 }

        expect(bet_coins).to eq 0
      end
    end
  end

  describe '#groups' do
    let(:user) { FactoryGirl.create(:user)}
    let!(:user_group) { FactoryGirl.create(:group, users: [user])}
    let!(:another_user_group) { FactoryGirl.create(:group, users: [user])}
    let!(:foreign_group) { FactoryGirl.create(:group)}

    it 'returns the groups of the user' do
      expect(user.groups).to have(2).items
      expect(user.groups).to match_array [user_group, another_user_group]
      expect(user.groups).not_to include foreign_group
    end
  end
end
