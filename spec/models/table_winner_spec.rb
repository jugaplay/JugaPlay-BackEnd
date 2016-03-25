require 'spec_helper'

describe TableWinner do
  describe 'validations' do
    it 'must have a table' do
      expect { FactoryGirl.create(:table_winner, table: FactoryGirl.create(:table)) }.not_to raise_error

      expect { FactoryGirl.create(:table_winner, table: nil) }.to raise_error ActiveRecord::RecordInvalid, /Table can't be blank/
    end
    
    it 'must have a unique user for each table' do
      user = FactoryGirl.create(:user)
      table = FactoryGirl.create(:table)

      expect { FactoryGirl.create(:table_winner, user: user, table: table) }.not_to raise_error
      expect { FactoryGirl.create(:table_winner, user: user) }.not_to raise_error

      expect { FactoryGirl.create(:table_winner, user: nil) }.to raise_error ActiveRecord::RecordInvalid, /User can't be blank/
      expect { FactoryGirl.create(:table_winner, user: user, table: table) }.to raise_error ActiveRecord::RecordInvalid, /User has already been taken/
    end
    
    it 'must have a unique position greater than 0 for each table' do
      table = FactoryGirl.create(:table)

      expect { FactoryGirl.create(:table_winner, table: table, position: 1) }.not_to raise_error

      expect { FactoryGirl.create(:table_winner, position: nil) }.to raise_error ActiveRecord::RecordInvalid, /Position can't be blank/
      expect { FactoryGirl.create(:table_winner, position: 0) }.to raise_error ActiveRecord::RecordInvalid, /Position must be greater than 0/
      expect { FactoryGirl.create(:table_winner, table: table, position: 1) }.to raise_error ActiveRecord::RecordInvalid, /Position has already been taken/
    end
  end
end
