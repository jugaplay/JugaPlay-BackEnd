require 'spec_helper'

describe PlayerStatsCSVImporter do
  let(:file) { File.open file_path }
  let(:importer) { PlayerStatsCSVImporter.new file }

  context 'when a valid file path is given' do
    context 'when the file includes valid features' do
      let(:file_path) { Rails.root + 'spec/fixtures/player_stats_with_valid_features.csv' }

      it 'imports the given player stats' do
        match = FactoryGirl.create(:match)
        match.id = 1
        match.save!

        errors = importer.import

        expect(PlayerStats.count).to eq 2
        expect(errors).to be_empty
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
