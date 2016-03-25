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
end
