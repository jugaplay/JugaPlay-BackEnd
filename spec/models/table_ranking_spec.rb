require 'spec_helper'

describe TableRanking do
  describe 'validations' do
    it 'must have a play' do
      expect { FactoryGirl.create(:table_ranking, play: FactoryGirl.create(:play)) }.not_to raise_error

      expect { FactoryGirl.create(:table_ranking, play: nil) }.to raise_error ActiveRecord::RecordInvalid, /Play can't be blank/
    end
    
    it 'must have some points' do
      expect { FactoryGirl.create(:table_ranking, points: 1) }.not_to raise_error

      expect { FactoryGirl.create(:table_ranking, points: nil) }.to raise_error ActiveRecord::RecordInvalid, /Points can't be blank/
      expect { FactoryGirl.create(:table_ranking, points: -1) }.to raise_error ActiveRecord::RecordInvalid, /Points must be greater than or equal to 0/
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
end
