require 'spec_helper'

describe TableRanking do
  describe 'validations' do
    it 'must have a play' do
      expect { FactoryGirl.create(:table_ranking, play: FactoryGirl.create(:play)) }.not_to raise_error

      expect { FactoryGirl.create(:table_ranking, play: nil) }.to raise_error ActiveRecord::RecordInvalid, /Play can't be blank/
    end
    
    it 'must have some points' do
      expect { FactoryGirl.create(:table_ranking, points: 0) }.not_to raise_error

      expect { FactoryGirl.create(:table_ranking, points: nil) }.to raise_error ActiveRecord::RecordInvalid, /Points can't be blank/
      expect { FactoryGirl.create(:table_ranking, points: -1) }.to raise_error ActiveRecord::RecordInvalid, /Points must be greater than or equal to 0/
    end

    it 'must have some earned coins' do
      expect { FactoryGirl.create(:table_ranking, earned_coins: 0) }.not_to raise_error

      expect { FactoryGirl.create(:table_ranking, earned_coins: nil) }.to raise_error ActiveRecord::RecordInvalid, /Earned coins can't be blank/
      expect { FactoryGirl.create(:table_ranking, earned_coins: -1) }.to raise_error ActiveRecord::RecordInvalid, /Earned coins must be greater than or equal to 0/
    end

    it 'must have a unique position greater than 0 per table' do
      table = FactoryGirl.create(:table)
      play = FactoryGirl.create(:play, table: table)

      expect { FactoryGirl.create(:table_ranking, play: play, position: 1) }.not_to raise_error

      expect { FactoryGirl.create(:table_ranking, position: nil) }.to raise_error ActiveRecord::RecordInvalid, /Position can't be blank/
      expect { FactoryGirl.create(:table_ranking, position: 0) }.to raise_error ActiveRecord::RecordInvalid, /Position must be greater than or equal to 1/
      expect { FactoryGirl.create(:table_ranking, play: FactoryGirl.create(:play, table: table), position: 1) }.to raise_error ActiveRecord::RecordInvalid, /Position has already been taken/
    end
  end

  describe '.by_user' do
    let(:user) { FactoryGirl.create(:user) }
    let(:another_user) { FactoryGirl.create(:user) }

    let!(:user_table_ranking) { FactoryGirl.create(:table_ranking, :for_user, user: user) }
    let!(:user_another_table_ranking) { FactoryGirl.create(:table_ranking, :for_user, user: user) }
    let!(:another_user_table_ranking) { FactoryGirl.create(:table_ranking, :for_user, user: another_user) }

    it 'includes only the rankings for the given user' do
      rankings = TableRanking.by_user(user)

      expect(rankings).to have(2).items
      expect(rankings).to include(user_table_ranking, user_another_table_ranking)
    end
  end
end
