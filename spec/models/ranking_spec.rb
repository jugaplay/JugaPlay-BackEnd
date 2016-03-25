require 'spec_helper'

describe Ranking do
  let(:tournament_a) { FactoryGirl.create(:tournament) }
  let(:tournament_b) { FactoryGirl.create(:tournament) }
  
  let(:first_user) { FactoryGirl.create(:user) }
  let(:second_user) { FactoryGirl.create(:user) }
  
  let!(:second_user_ranking_for_a) { FactoryGirl.create(:ranking, tournament: tournament_a, user: second_user, position: 50, points: 100) }
  let!(:first_user_ranking_for_a) { FactoryGirl.create(:ranking, tournament: tournament_a, user: first_user, position: 206, points: 1) }
  let!(:first_user_ranking_for_b) { FactoryGirl.create(:ranking, tournament: tournament_b, user: first_user, position: 1, points: 1) }

  describe 'validations' do
    it 'must have a user' do
      expect { FactoryGirl.create(:ranking, user: nil) }.to raise_error ActiveRecord::RecordInvalid, /User can't be blank/

      expect { FactoryGirl.create(:ranking, user: first_user) }.not_to raise_error
    end

    it 'must have a tournament' do
      expect { FactoryGirl.create(:ranking, tournament: nil) }.to raise_error ActiveRecord::RecordInvalid, /Tournament can't be blank/

      expect { FactoryGirl.create(:ranking, tournament: tournament_a) }.not_to raise_error
    end

    it 'must have an integer position greater than zero' do
      expect { FactoryGirl.create(:ranking, position: -1) }.to raise_error ActiveRecord::RecordInvalid, /Position must be greater than 0/
      expect { FactoryGirl.create(:ranking, position: 0) }.to raise_error ActiveRecord::RecordInvalid, /Position must be greater than 0/
      expect { FactoryGirl.create(:ranking, position: 1.1) }.to raise_error ActiveRecord::RecordInvalid, /Position must be an integer/

      expect { FactoryGirl.create(:ranking, position: 1) }.not_to raise_error
    end

    it 'must have points greater or equal than zero' do
      expect { FactoryGirl.create(:ranking, points: -1) }.to raise_error ActiveRecord::RecordInvalid, /Points must be greater than or equal to 0/

      expect { FactoryGirl.create(:ranking, points: 0) }.not_to raise_error
      expect { FactoryGirl.create(:ranking, points: 1) }.not_to raise_error
      expect { FactoryGirl.create(:ranking, points: 1.1) }.not_to raise_error
    end

    it 'can not be two rankings for the same user and same tournament' do
      expect { FactoryGirl.create(:ranking, user: first_user, tournament: tournament_a) }.to raise_error ActiveRecord::RecordInvalid, /User has already been taken/
    end

    it 'can not be two rankings for the same tournament with the same position' do
      FactoryGirl.create(:ranking, tournament: tournament_a, position: 100)

      expect { FactoryGirl.create(:ranking, tournament: tournament_b, position: 100) }.not_to raise_error
      expect { FactoryGirl.create(:ranking, tournament: tournament_a, position: 100) }.to raise_error ActiveRecord::RecordInvalid, /Position has already been taken/
    end
  end

  describe '.for_tournament' do
    it 'returns the rankings for the given tournament' do
      rankings_for_tournament_a = Ranking.for_tournament(tournament_a)
      
      expect(rankings_for_tournament_a).to include first_user_ranking_for_a, second_user_ranking_for_a 
      expect(rankings_for_tournament_a).not_to include first_user_ranking_for_b 
    end
  end
  
  describe '.of_user' do
    it 'returns the rankings of the given user' do
      rankings_of_first_user = Ranking.of_user(first_user)
      
      expect(rankings_of_first_user).to include first_user_ranking_for_a, first_user_ranking_for_b
      expect(rankings_of_first_user).not_to include second_user_ranking_for_a 
    end
  end

  describe '.highest_in_tournament' do
    it 'returns the highest positioned ranking in the given tournament' do
      expect(Ranking.highest_in_tournament(tournament_a)).to eq second_user_ranking_for_a
      expect(Ranking.highest_in_tournament(tournament_b)).to eq first_user_ranking_for_b
    end
  end
end
