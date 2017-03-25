require 'spec_helper'

describe Play do
  describe 'validations' do
    it 'must have a user' do
      expect { FactoryGirl.create(:play, user: FactoryGirl.create(:user)) }.not_to raise_error

      expect { FactoryGirl.create(:play, user: nil) }.to raise_error ActiveRecord::RecordInvalid, /User can't be blank/
    end

    it 'must have a table' do
      expect { FactoryGirl.create(:play, table: FactoryGirl.create(:table)) }.not_to raise_error

      expect { FactoryGirl.create(:play, table: nil) }.to raise_error ActiveRecord::RecordInvalid, /Table can't be blank/
    end

    it 'must have unique players and at least one' do
      expect { FactoryGirl.create(:play, players: [FactoryGirl.create(:player)]) }.not_to raise_error

      expect { Play.create!(user: FactoryGirl.create(:user), table: FactoryGirl.create(:table)) }.to raise_error ActiveRecord::RecordInvalid, /Players can't be blank/
      expect { Play.last.players << Play.last.players.first }.to raise_error
    end

    it 'can be only one play per user on the same table' do
      user = FactoryGirl.create(:user)
      table = FactoryGirl.create(:table)
      FactoryGirl.create(:play, user: user, table: table)

      expect { FactoryGirl.create(:play, user: user, table: table) }.to raise_error ActiveRecord::RecordInvalid, /User has already been taken/
    end

    it 'can have no points' do
      expect { FactoryGirl.create(:play, points: nil) }.not_to raise_error
      expect { FactoryGirl.create(:play, points: -1) }.not_to raise_error
      expect { FactoryGirl.create(:play, points: 0) }.not_to raise_error
      expect { FactoryGirl.create(:play, points: 5) }.not_to raise_error
      expect { FactoryGirl.create(:play, points: 5.5) }.not_to raise_error
    end

    it 'can have no bet coins equal or greater than zero' do
      expect { FactoryGirl.create(:play, bet_coins: 0) }.not_to raise_error
      expect { FactoryGirl.create(:play, bet_coins: 5) }.not_to raise_error

      expect { FactoryGirl.create(:play, bet_coins: nil) }.to raise_error ActiveRecord::RecordInvalid, /Bet coins is not a number/
      expect { FactoryGirl.create(:play, bet_coins: -1) }.to raise_error ActiveRecord::RecordInvalid, /Bet coins must be greater than or equal to 0/
      expect { FactoryGirl.create(:play, bet_coins: 5.5) }.to raise_error ActiveRecord::RecordInvalid, /Bet coins must be an integer/
    end
  end

  describe '#earned_coins' do
    let(:play) { FactoryGirl.create(:play) }

    context 'when the play has a prize' do
      let!(:table_ranking) { FactoryGirl.create(:table_ranking, play: play, position: 10, earned_coins: 10) }

      it 'returns the coins that the user earned in that table' do
        expect(play.earned_coins).to eq 10
      end
    end

    context 'when the play did not have a table ranking' do
      it 'returns N/A when no block is given' do
        expect(play.earned_coins).to eq 'N/A'
      end

      it 'returns calls the given block if given' do
        earned_coins = play.earned_coins { 'unknown' }

        expect(earned_coins).to eq 'unknown'
      end
    end
  end

  describe '#position' do
    let(:play) { FactoryGirl.create(:play) }

    context 'when the play has a table ranking' do
      let!(:table_ranking) { FactoryGirl.create(:table_ranking, play: play, position: 10) }

      it 'returns the coins that the user earned in that table' do
        expect(play.position).to eq 10
      end
    end

    context 'when the play did not have a table ranking' do
      it 'returns N/A when no block is given' do
        expect(play.position).to eq 'N/A'
      end

      it 'returns calls the given block if given' do
        position = play.position { -1 }

        expect(position).to eq -1
      end
    end
  end

  describe '#points_for_ranking' do
    let(:play) { FactoryGirl.create(:play, points: 10) }

    context 'when the play has a table ranking' do
      let!(:table_ranking) { FactoryGirl.create(:table_ranking, play: play, position: 10, points: 200) }

      it 'returns the points for the ranking that the user earned in that table' do
        expect(play.points_for_ranking).to eq 200
      end
    end

    context 'when the play did not have a table ranking' do
      it 'returns N/A when no block is given' do
        expect(play.points_for_ranking).to eq 'N/A'
      end

      it 'returns calls the given block if given' do
        points_for_ranking = play.points_for_ranking { 0 }

        expect(points_for_ranking).to eq 0
      end
    end
  end

  describe '#points' do
    context 'when the play has some points' do
      let!(:play) { FactoryGirl.create(:play, points: 10) }

      it 'returns the points for the ranking that the user earned in that table' do
        expect(play.points).to eq 10
      end
    end

    context 'when the play does not have any points assigned yet' do
      let!(:play) { FactoryGirl.create(:play) }

      it 'returns nil when no block is given' do
        expect(play.points).to be_nil
      end

      it 'returns calls the given block if given' do
        points = play.points { 'N/A' }

        expect(points).to eq 'N/A'
      end
    end
  end
end
