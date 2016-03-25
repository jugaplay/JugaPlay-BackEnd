require 'spec_helper'

describe PlayerStatsCSVImporter do
  let(:importer) { PlayerStatsCSVImporter.new file, table }
  let(:table) { FactoryGirl.create(:table, matches: [FactoryGirl.create(:match, tournament: tournament)], tournament: tournament) }
  let(:tournament) { FactoryGirl.create(:tournament) }
  let(:file) { File.open file_path }

  context 'when a valid file path is given' do
    context 'when the file includes valid features' do
      let(:file_path) { Rails.root + 'spec/fixtures/player_stats_with_valid_features.csv' }

      context 'when the given table includes the matches included in the file' do
        it 'imports the given player stats' do
          match = table.matches.first
          match.id = 1
          match.save!

          expect { importer.import }.to change { PlayerStats.count }.by 2
        end
      end

      context 'when the given table does not include all the matches included in the file' do
        it 'raises an error' do
          table.update_attributes(matches: [FactoryGirl.create(:match, tournament: table.tournament)])

          expect { importer.import }.to raise_error ArgumentError, 'Match not included in the given table'
        end
      end
    end

    context 'when the file includes any invalid feature' do
      let(:file_path) { Rails.root + 'spec/fixtures/player_stats_with_invalid_features.csv' }

      it 'raises an error' do
        expect { importer.import }.to raise_error, ActiveRecord::UnknownAttributeError
      end
    end
  end

  context 'when no file path is given' do
    let(:file) { nil }

    it 'raises an error' do
      expect { importer }.to raise_error ArgumentError
    end
  end
end
