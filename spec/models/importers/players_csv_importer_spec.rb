require 'spec_helper'

describe PlayersCSVImporter do
  let(:importer) { PlayersCSVImporter.new team, file }
  let!(:team) { FactoryGirl.create(:team).tap { |team| team.update_attributes(players: []) } }
  let(:file) { File.open file_path }
  let(:file_path) { Rails.root + 'spec/fixtures/players_with_valid_data.csv' }

  context 'when a valid file path is given' do
    context 'when the file includes valid data' do
      it 'imports the given players for the given team' do
        expect { importer.import }.to change { Player.count }.by 2

        expect(team.reload.players).to have(2).items

        first_player = team.players.first
        expect(first_player.first_name).to eq 'Diego'
        expect(first_player.last_name).to eq 'Rodriguez'
        expect(first_player.position).to eq Position::GOALKEEPER
        expect(first_player.description).to eq 'arquero mediocre'
        expect(first_player.birthday).to eq Date.new(1989, 6, 25)
        expect(first_player.nationality).to eq Country::ARGENTINA
        expect(first_player.weight).to eq 80
        expect(first_player.height).to eq 1.90
        expect(first_player.data_factory_id_if_none { fail }).to eq 200
        expect(first_player.team).to eq team

        second_player = team.players.last
        expect(second_player.first_name).to eq 'Rodrigo'
        expect(second_player.last_name).to eq 'Mora'
        expect(second_player.position).to eq Position::FORWARD
        expect(second_player.description).to eq 'el mejor delantero del mundo'
        expect(second_player.birthday).to eq Date.new(1991, 8, 12)
        expect(second_player.nationality).to eq Country::URUGUAY
        expect(second_player.weight).to eq 75
        expect(second_player.height).to eq 1.75
        expect(second_player.data_factory_id_if_none { fail }).to eq 100
        expect(second_player.team).to eq team
      end
    end

    context 'when the file includes any invalid data' do
      let(:file_path) { Rails.root + 'spec/fixtures/players_with_invalid_data.csv' }

      xit 'raises an error' do

      end
    end
  end

  context 'when no file path is given' do
    let(:file) { nil }

    it 'raises an error' do
      expect { importer }.to raise_error ArgumentError
    end
  end

  context 'when no team is given' do
    let(:team) { nil }

    it 'raises an error' do
      expect { importer }.to raise_error ArgumentError
    end
  end
end
