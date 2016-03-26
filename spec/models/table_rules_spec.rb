require 'spec_helper'

describe TableRules do
  describe 'validations' do
    it 'must have a unique table' do
      table = FactoryGirl.create(:table)

      expect { FactoryGirl.create(:table_rules, table: table) }.not_to raise_error

      expect { FactoryGirl.create(:table_rules, table: nil) }.to raise_error ActiveRecord::RecordInvalid, /Table can't be blank/
      expect { FactoryGirl.create(:table_rules, table: table) }.to raise_error ActiveRecord::RecordInvalid, /Table has already been taken/
    end

    it 'must include a value for all the feature stats' do
      PlayerStats::FEATURES.each do |feature|
        expect { FactoryGirl.create(:table_rules, feature => 0) }.not_to raise_error
        expect { FactoryGirl.create(:table_rules, feature => 0.5) }.not_to raise_error
        expect { FactoryGirl.create(:table_rules, feature => -1) }.not_to raise_error
        expect { FactoryGirl.create(:table_rules, feature => 10) }.not_to raise_error

        expect { FactoryGirl.create(:table_rules, feature => nil) }.to raise_error ActiveRecord::RecordInvalid, /can't be blank/
      end
    end
  end
end
