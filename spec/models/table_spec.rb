require 'spec_helper'

describe Table do
  describe 'validations' do
    it 'must have a title' do
      expect { FactoryGirl.create(:table, title: 'Supreclasicos') }.not_to raise_error

      expect { FactoryGirl.create(:table, title: nil) }.to raise_error ActiveRecord::RecordInvalid, /Title can't be blank/
    end

    it 'must have a description' do
      expect { FactoryGirl.create(:table, description: 'una descripción') }.not_to raise_error

      expect { FactoryGirl.create(:table, description: nil) }.to raise_error ActiveRecord::RecordInvalid, /Description can't be blank/
    end

    it 'must have an integer number of players greater than 0' do
      expect { FactoryGirl.create(:table, number_of_players: 5) }.not_to raise_error

      expect { FactoryGirl.create(:table, number_of_players: 1.5) }.to raise_error ActiveRecord::RecordInvalid, /Number of players must be an integer/
      expect { FactoryGirl.create(:table, number_of_players: 0) }.to raise_error ActiveRecord::RecordInvalid, /Number of players must be greater than 0/
      expect { FactoryGirl.create(:table, number_of_players: nil) }.to raise_error ActiveRecord::RecordInvalid, /Number of players can't be blank/
    end

    it 'must have an integer number of players greater than or equal 0' do
      expect { FactoryGirl.create(:table, entry_coins_cost: 0) }.not_to raise_error
      expect { FactoryGirl.create(:table, entry_coins_cost: 5) }.not_to raise_error

      expect { FactoryGirl.create(:table, entry_coins_cost: nil) }.to raise_error ActiveRecord::RecordInvalid, /Entry coins cost can't be blank/
      expect { FactoryGirl.create(:table, entry_coins_cost: -1) }.to raise_error ActiveRecord::RecordInvalid, /Entry coins cost must be greater than or equal to 0/
      expect { FactoryGirl.create(:table, entry_coins_cost: 1.5) }.to raise_error ActiveRecord::RecordInvalid, /Entry coins cost must be an integer/
    end

    it 'must have an start time' do
      expect { FactoryGirl.create(:table, start_time: DateTime.now) }.not_to raise_error

      expect { Table.last.update_attributes!(start_time: nil) }.to raise_error ActiveRecord::RecordInvalid, /Start time can't be blank/
    end

    it 'must have an end time' do
      expect { FactoryGirl.create(:table, start_time: DateTime.now, end_time: DateTime.now + 1.day) }.not_to raise_error

      expect { Table.last.update_attributes!(end_time: nil) }.to raise_error ActiveRecord::RecordInvalid, /End time can't be blank/
      expect { Table.last.update_attributes!(start_time: DateTime.now, end_time: DateTime.now) }.to raise_error ActiveRecord::RecordInvalid, /End time must be after/
    end

    it 'can have no points for winners' do
      expect { FactoryGirl.create(:table, points_for_winners: []) }.not_to raise_error
      expect { FactoryGirl.create(:table, points_for_winners: [100, 50, 20]) }.not_to raise_error

      expect { FactoryGirl.create(:table, points_for_winners: [0]) }.to raise_error ActiveRecord::RecordInvalid, /has a value that must be greater than 0/
      expect { FactoryGirl.create(:table, points_for_winners: [100, nil]) }.to raise_error ActiveRecord::RecordInvalid, /has a value that is not a number/
    end

    it 'can have no coins for winners or have coins for winners greater than 0' do
      expect { FactoryGirl.create(:table, coins_for_winners: []) }.not_to raise_error
      expect { FactoryGirl.create(:table, coins_for_winners: [100, 50, 20]) }.not_to raise_error

      expect { FactoryGirl.create(:table, coins_for_winners: [0]) }.to raise_error ActiveRecord::RecordInvalid, /has a value that must be greater than 0/
      expect { FactoryGirl.create(:table, coins_for_winners: [100, nil]) }.to raise_error ActiveRecord::RecordInvalid, /has a value that is not a number/
    end

    it 'can have a set of matches belonging to the same tournament' do
      tournament = FactoryGirl.create(:tournament)
      another_tournament = FactoryGirl.create(:tournament)

      match_from_same_tournament = FactoryGirl.create(:match, tournament: tournament)
      match_from_another_tournament = FactoryGirl.create(:match, tournament: another_tournament)

      expect { FactoryGirl.create(:table, tournament: tournament, matches: [match_from_same_tournament, match_from_another_tournament]) }.to raise_error ActiveRecord::RecordInvalid, /Matches do not belong to given tournament/
    end
  end
  
  describe '#did_not_play?' do
    let!(:table) { FactoryGirl.create(:table) }
    let!(:user) { FactoryGirl.create(:user) }
    
    context 'when a user has not played in that table' do
      it 'returns true' do
        expect(table.did_not_play? user).to eq true
      end
    end
    
    context 'when a user has played in that table' do
      it 'returns false' do
        players = Player.all.sample(table.number_of_players)
        PlaysCreator.for(table).create_play(players: players, user: user)

        expect(table.did_not_play? user).to eq false
      end
    end
  end

  describe '#can_play_with_amount_of_players?' do
    let!(:table) { FactoryGirl.create(:table, number_of_players: 4) }
    let(:players) { number_of_player_to_play.times.map { FactoryGirl.create(:player) } }

    context 'when the amount of players given is equal to the available for the table' do
      let(:number_of_player_to_play) { table.number_of_players }

      it 'returns true' do
        expect(table.can_play_with_amount_of_players? players).to eq true
      end
    end

    context 'when the amount of players given is greater than the available for the table' do
      let(:number_of_player_to_play) { table.number_of_players + 1 }

      it 'returns false' do
        expect(table.can_play_with_amount_of_players? players).to eq false
      end
    end

    context 'when the amount of players given is lower than the available for the table' do
      let(:number_of_player_to_play) { table.number_of_players - 1 }

      it 'returns false' do
        expect(table.can_play_with_amount_of_players? players).to eq false
      end
    end
  end

  describe '#include_all_players?' do
    let(:table) { FactoryGirl.create(:table) }

    context 'when all the given players are playing in any of the included matches' do
      let(:players) { table.matches.sample.local_team.players.sample(table.number_of_players) }

      it 'returns true' do
        expect(table.include_all_players? players).to eq true
      end
    end

    context 'when any of the given players is not playing in any of the included matches' do
      let(:players) { table.matches.sample.local_team.players.sample(table.number_of_players) + [FactoryGirl.create(:player)] }

      it 'returns false' do
        expect(table.include_all_players? players).to eq false
      end
    end
  end

  describe '#amount_of_users_playing' do
    let!(:table) { FactoryGirl.create(:table) }

    it 'returns the amount of plays that are taking place in that table' do
      FactoryGirl.create(:play, table: table)
      FactoryGirl.create(:play, table: FactoryGirl.create(:table))

      expect(table.amount_of_users_playing).to eq 1
    end
  end

  describe '#players' do
    let(:tournament) { FactoryGirl.create(:tournament) }
    let(:table) { FactoryGirl.create(:table, matches: matches, tournament: tournament) }

    context 'when the table has no matches' do
      let(:matches) { [] }
      before { table.update_attributes!(matches: matches) }

      it 'returns an empty list' do
        expect(table.reload.players).to be_empty
      end
    end

    context 'when the table one match' do
      let(:match) { FactoryGirl.create(:match, tournament: tournament) }
      let(:matches) { [match] }

      it 'returns the players of the match' do
        expect(table.players).to match_array match.players
      end
    end

    context 'when the table two matches with the same team' do
      let(:match) { FactoryGirl.create(:match, tournament: tournament) }
      let(:another_match) { FactoryGirl.create(:match, tournament: tournament, local_team: match.local_team) }
      let(:matches) { [match, another_match] }

      it 'returns the players of the match without duplications' do
        local_team_players = match.local_team.players
        visitor_team_players = match.visitor_team.players
        another_visitor_team_players = another_match.visitor_team.players

        players = table.players

        expect(players).to have(local_team_players.size + visitor_team_players.size + another_visitor_team_players.size).items
        expect(players).to match_array (local_team_players + visitor_team_players + another_visitor_team_players)
      end
    end
  end

  describe '.privates_for' do
    let(:user) { FactoryGirl.create(:user) }
    let(:another_user) { FactoryGirl.create(:user) }
    let!(:public_table) { FactoryGirl.create(:table) }
    let!(:private_table_for_user) { FactoryGirl.create(:table, group: FactoryGirl.create(:group, users: [user])) }
    let!(:private_table_for_another_user) { FactoryGirl.create(:table, group: FactoryGirl.create(:group, users: [another_user])) }

    it 'only gives the private table including the giving user' do
      tables_for_user = Table.privates_for user
      tables_for_another_user = Table.privates_for another_user

      expect(tables_for_user).to have(1).item
      expect(tables_for_user).to include private_table_for_user
      expect(tables_for_user).not_to include private_table_for_another_user
      expect(tables_for_user).not_to include public_table

      expect(tables_for_another_user).to have(1).item
      expect(tables_for_another_user).to include private_table_for_another_user
      expect(tables_for_another_user).not_to include private_table_for_user
      expect(tables_for_another_user).not_to include public_table
    end
  end
end
