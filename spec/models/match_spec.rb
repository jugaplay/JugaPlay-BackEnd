require 'spec_helper'

describe Match do
  describe 'validations' do
    it 'must have a title' do
      expect { FactoryGirl.create(:match, title: 'River vs Boca') }.not_to raise_error

      expect { FactoryGirl.create(:match, title: nil) }.to raise_error ActiveRecord::RecordInvalid, /Title can't be blank/
    end

    it 'must have a local team and a visitor team' do
      river = FactoryGirl.create(:team, name: 'River')
      boca = FactoryGirl.create(:team, name: 'Boca')

      expect { FactoryGirl.create(:match, local_team: river) }.not_to raise_error
      expect { FactoryGirl.create(:match, visitor_team: boca) }.not_to raise_error

      expect { FactoryGirl.create(:match, local_team: nil) }.to raise_error ActiveRecord::RecordInvalid, /Local team can't be blank/
      expect { FactoryGirl.create(:match, visitor_team: nil) }.to raise_error ActiveRecord::RecordInvalid, /Visitor team can't be blank/
      expect { FactoryGirl.create(:match, local_team: river, visitor_team: river) }.to raise_error ActiveRecord::RecordInvalid, /Visitor team must be different from local team/
    end

    it 'must have a datetime' do
      expect { FactoryGirl.create(:match, datetime: DateTime.now) }.not_to raise_error

      expect { FactoryGirl.create(:match, datetime: nil) }.to raise_error ActiveRecord::RecordInvalid, /Datetime can't be blank/
    end

    it 'must be unique' do
      match = FactoryGirl.create(:match, datetime: DateTime.yesterday)

      expect { FactoryGirl.create(:match, local_team: match.local_team, visitor_team: match.visitor_team, datetime: DateTime.now) }.not_to raise_error

      expect { FactoryGirl.create(:match, local_team: match.local_team, visitor_team: match.visitor_team, datetime: match.datetime) }.to raise_error ActiveRecord::RecordInvalid, /Datetime has already been taken/
    end

    it 'must have a tournament' do
      match = FactoryGirl.create(:match, tournament: FactoryGirl.create(:tournament))

      expect { FactoryGirl.create(:match, tournament: nil) }.to raise_error ActiveRecord::RecordInvalid, /Tournament can't be blank/
    end
  end

  describe '#players' do
    let(:match) { FactoryGirl.create(:match) }

    it 'returns a list including both team players' do
      local_team_players = match.local_team.players
      visitor_team_players = match.visitor_team.players

      players = match.players

      expect(players).to have(local_team_players.size + visitor_team_players.size).items
      (local_team_players + visitor_team_players).each { |player| expect(players).to include player }
    end
  end

  describe '#is_played_by?' do
    let(:match) { FactoryGirl.create(:match) }

    context 'when no player is given' do
      let(:player) { nil }

      it 'returns false' do
        expect(match.is_played_by? player).to eq false
      end
    end

    context 'when a player is given' do
      context 'when the local team includes that player' do
        let(:player) { match.local_team.players.sample }

        it 'returns true' do
          expect(match.is_played_by? player).to eq true
        end
      end

      context 'when the visitor team includes that player' do
        let(:player) { match.visitor_team.players.sample }

        it 'returns true' do
          expect(match.is_played_by? player).to eq true
        end
      end

      context 'when no team includes that player' do
        let(:player) { FactoryGirl.create(:player) }

        it 'returns false' do
          expect(match.is_played_by? player).to eq false
        end
      end
    end
  end

  describe 'scopes' do
    let!(:match_without_stats) { FactoryGirl.create(:match) }
    let!(:match_with_complete_stats) { FactoryGirl.create(:match) }
    let!(:match_with_complete_local_stats_and_without_visitor_stats) { FactoryGirl.create(:match) }
    let!(:match_with_complete_local_stats_and_incomplete_visitor_stats) { FactoryGirl.create(:match) }
    let!(:match_with_complete_visitor_stats_and_without_local_stats) { FactoryGirl.create(:match) }
    let!(:match_with_complete_visitor_stats_and_incomplete_local_stats) { FactoryGirl.create(:match) }

    before do
      create_empty_stats_for match_with_complete_stats

      create_empty_stats_for_local_team match_with_complete_local_stats_and_without_visitor_stats
      create_empty_stats_for_local_team match_with_complete_local_stats_and_incomplete_visitor_stats
      create_empty_stats_for_player match_with_complete_local_stats_and_incomplete_visitor_stats, match_with_complete_local_stats_and_incomplete_visitor_stats.visitor_team.players.first

      create_empty_stats_for_visitor_team match_with_complete_visitor_stats_and_without_local_stats
      create_empty_stats_for_visitor_team match_with_complete_visitor_stats_and_incomplete_local_stats
      create_empty_stats_for_player match_with_complete_visitor_stats_and_incomplete_local_stats, match_with_complete_visitor_stats_and_incomplete_local_stats.local_team.players.first
    end

    describe '.with_incomplete_local_stats' do
      it 'includes only the matches with incomplete local stats' do
        matches = Match.with_incomplete_local_stats

        expect(matches).to have(3).item
        expect(matches).to include match_without_stats,
                                   match_with_complete_visitor_stats_and_without_local_stats,
                                   match_with_complete_visitor_stats_and_incomplete_local_stats
      end
    end

    describe '.with_incomplete_visitor_stats' do
      it 'includes only the matches with incomplete visitor stats' do
        matches = Match.with_incomplete_visitor_stats

        expect(matches).to have(3).item
        expect(matches).to include match_without_stats,
                                   match_with_complete_local_stats_and_without_visitor_stats,
                                   match_with_complete_local_stats_and_incomplete_visitor_stats
      end
    end

    describe '.with_incomplete_stats' do
      it 'includes only the matches with incomplete stats' do
        matches = Match.with_incomplete_stats

        expect(matches).to have(5).item
        expect(matches).to include match_without_stats,
                                   match_with_complete_local_stats_and_without_visitor_stats,
                                   match_with_complete_local_stats_and_incomplete_visitor_stats,
                                   match_with_complete_visitor_stats_and_without_local_stats,
                                   match_with_complete_visitor_stats_and_incomplete_local_stats
      end
    end
  end
end
