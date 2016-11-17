require 'spec_helper'

describe PlayerStatsCSVImporter do
  let(:file) { File.open file_path }
  let(:importer) { PlayerStatsCSVImporter.new file }

  context 'when a valid file path is given' do
    context 'when the file includes valid features' do
      let(:match) { FactoryGirl.create(:match) }
      let(:one_player) { match.local_team.players.first }
      let(:another_player) { match.visitor_team.players.first }
      let(:match) { FactoryGirl.create(:match) }
      let(:file_path) { Rails.root + 'spec/fixtures/player_stats_with_valid_features.csv' }

      it 'imports the given player stats' do
        data = "player_id,match_id,assists,defender_scored_goals,faults,free_kick_goal,goalkeeper_scored_goals,missed_penalties,missed_saves,offside,recoveries,red_cards,right_passes,saved_penalties,saves,scored_goals,shots,shots_on_goal,shots_outside,shots_to_the_post,undefeated_defense,undefeated_goal,winner_team,wrong_passes,yellow_cards
                #{one_player.id},#{match.id},0,0,0,0,0,0,0,0,0,0,10,0,0,0,0,0,0,0,0,0,0,0.0,0
                #{another_player.id},#{match.id},0,0,2,0,0,0,0,0,2,0,20,0,2,0,0,0,0,0,0,0,0,2.0,0"
        expect(File).to receive(:read).with(file.path).and_return StringIO.new(data)

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
