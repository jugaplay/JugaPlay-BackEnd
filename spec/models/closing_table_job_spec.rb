require 'spec_helper'

describe ClosingTableJob do
  describe 'validations' do
    let(:table) { FactoryGirl.create(:table) }

    it 'must have a table' do
      expect { FactoryGirl.create(:closing_table_job, table: table) }.not_to raise_error

      expect { FactoryGirl.create(:closing_table_job, table: nil) }.to raise_error ActiveRecord::RecordInvalid, /Table can't be blank/
      expect { FactoryGirl.create(:closing_table_job, table: table) }.to raise_error ActiveRecord::RecordInvalid, /Table has already been taken/
    end

    it 'must have an integer priority greater than 0' do
      expect { FactoryGirl.create(:closing_table_job, priority: 1) }.not_to raise_error

      expect { FactoryGirl.create(:closing_table_job, priority: 1) }.to raise_error ActiveRecord::RecordInvalid, /Priority has already been taken/
      expect { FactoryGirl.create(:closing_table_job, priority: 1.5) }.to raise_error ActiveRecord::RecordInvalid, /Priority must be an integer/
      expect { FactoryGirl.create(:closing_table_job, priority: 0) }.to raise_error ActiveRecord::RecordInvalid, /Priority must be greater than 0/
      expect { FactoryGirl.create(:closing_table_job, priority: nil) }.to raise_error ActiveRecord::RecordInvalid, /Priority can't be blank/
    end

    it 'must have a status' do
      expect { FactoryGirl.create(:closing_table_job, status: :pending) }.not_to raise_error
      expect { FactoryGirl.create(:closing_table_job, status: :finished_successfully) }.not_to raise_error
      expect { FactoryGirl.create(:closing_table_job, status: :failed) }.not_to raise_error

      expect { FactoryGirl.create(:closing_table_job, status: nil) }.to raise_error ActiveRecord::RecordInvalid, /Status can't be blank/
      expect { FactoryGirl.create(:closing_table_job, status: :unknown) }.to raise_error ActiveRecord::RecordInvalid, /Status can't be blank/
    end
  end

  describe '.ordered' do
    let(:first_job) { FactoryGirl.create(:closing_table_job, priority: 1) }
    let(:second_job) { FactoryGirl.create(:closing_table_job, priority: 2) }
    let(:third_job) { FactoryGirl.create(:closing_table_job, priority: 3) }

    it 'returns the closing table jobs ordered by priority' do
      second_job
      third_job
      first_job

      jobs = ClosingTableJob.ordered

      expect(jobs).to have(3).items
      expect(jobs.first).to eq first_job
      expect(jobs.second).to eq second_job
      expect(jobs.third).to eq third_job
    end
  end
end
