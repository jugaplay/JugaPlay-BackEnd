require 'spec_helper'

describe ClosingTablesWorker do
  let(:worker) { ClosingTablesWorker.for_all_tables_to_be_closed }
  let(:yesterday) { Time.now - 1.day }

  context 'given multiple closing table jobs' do
    let!(:opened_table) { FactoryGirl.create(:table, status: :opened, end_time: yesterday) }
    let!(:another_opened_table) { FactoryGirl.create(:table, status: :opened, end_time: yesterday) }
    let!(:being_closed_table) { FactoryGirl.create(:table, status: :being_closed, end_time: yesterday) }
    let!(:closed_table) { FactoryGirl.create(:table, status: :closed, end_time: yesterday) }

    before do
      create_empty_stats_for_all opened_table.matches
      create_empty_stats_for_all another_opened_table.matches
      create_empty_stats_for_all being_closed_table.matches
      create_empty_stats_for_all closed_table.matches
    end

    it 'creates a closing table job for each opened table with valid stats' do
      errors = worker.call
      jobs = ClosingTableJob.all

      expect(errors).to be_empty
      expect(jobs).to have(2).items
      expect(jobs.first.table).to eq opened_table
      expect(jobs.first.priority).to eq 1
      expect(jobs.first.status).to eq :pending
      expect(jobs.second.table).to eq another_opened_table
      expect(jobs.second.priority).to eq 2
      expect(jobs.second.status).to eq :pending

      expect(opened_table.reload.status).to eq :being_closed
      expect(another_opened_table.reload.status).to eq :being_closed
      expect(being_closed_table.reload.status).to eq :being_closed
      expect(closed_table.reload.status).to eq :closed
    end
  end
end
