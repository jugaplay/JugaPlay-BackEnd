require 'spec_helper'

describe Table do
  describe 'validations' do
    it 'must have a title' do
      expect { FactoryGirl.create(:table, title: 'Supreclasicos') }.not_to raise_error

      expect { FactoryGirl.create(:table, title: nil) }.to raise_error ActiveRecord::RecordInvalid, /Title can't be blank/
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

    it 'must have points for winners greater than 0' do
      expect { FactoryGirl.create(:table, points_for_winners: [100, 50, 20]) }.not_to raise_error

      expect { FactoryGirl.create(:table, points_for_winners: []) }.to raise_error ActiveRecord::RecordInvalid, /Points for winners can't be blank/
      expect { FactoryGirl.create(:table, points_for_winners: [0]) }.to raise_error ActiveRecord::RecordInvalid, /has a value that must be greater than 0/
      expect { FactoryGirl.create(:table, points_for_winners: [100, nil]) }.to raise_error ActiveRecord::RecordInvalid, /has a value that is not a number/
    end

    it 'can have a set of matches belonging to the same tournament' do
      tournament = FactoryGirl.create(:tournament)
      another_tournament = FactoryGirl.create(:tournament)

      match_from_same_tournament = FactoryGirl.create(:match, tournament: tournament)
      match_from_another_tournament = FactoryGirl.create(:match, tournament: another_tournament)

      expect { FactoryGirl.create(:table, tournament: tournament, matches: [match_from_same_tournament, match_from_another_tournament]) }.to raise_error ActiveRecord::RecordInvalid, /Matches do not belong to given tournament/
    end
  end
  
  describe '#can_play_user?' do
    let!(:table) { FactoryGirl.create(:table) }
    let!(:user) { FactoryGirl.create(:user) }
    
    context 'when a user has not played in that table' do
      it 'returns true' do
        expect(table.can_play_user? user).to eq true
      end
    end
    
    context 'when a user has played in that table' do
      it 'returns false' do
        players = Player.all.sample(table.number_of_players)
        Croupier.for(table).play(players: players, user: user)

        expect(table.can_play_user? user).to eq false
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

  describe '#position' do
    let(:table) { FactoryGirl.create(:table) }
    let(:first_place_user) { FactoryGirl.create(:user) }
    let(:second_place_user) { FactoryGirl.create(:user) }
    let!(:first_winner) { FactoryGirl.create(:table_winner, table: table, position: 1, user: first_place_user) }
    let!(:second_winner) { FactoryGirl.create(:table_winner, table: table, position: 2, user: second_place_user) }

    context 'when the given user was a winner' do
      it 'returns the winner of that play' do
        expect(table.position(first_place_user)).to eq 1
        expect(table.position(second_place_user)).to eq 2
      end
    end

    context 'when the given user was not a winner' do
      it 'evaluates the given block' do
        unknown_user = FactoryGirl.create(:user)

        expect(table.position(unknown_user) { 'unknown' }).to eq 'unknown'
      end
    end
  end

  describe '#payed_points' do
    let(:table) { FactoryGirl.create(:table) }
    let(:first_place_user) { FactoryGirl.create(:user) }
    let(:second_place_user) { FactoryGirl.create(:user) }
    let!(:first_winner) { FactoryGirl.create(:table_winner, table: table, position: 1, user: first_place_user) }
    let!(:second_winner) { FactoryGirl.create(:table_winner, table: table, position: 2, user: second_place_user) }

    context 'when the given user was a winner' do
      it 'returns the points that the table payed to that winner position' do
        expected_points_for_winner = table.points_for_winners[0]
        expected_points_for_another_winner = table.points_for_winners[1]

        expect(table.payed_points(first_place_user)).to eq expected_points_for_winner
        expect(table.payed_points(second_place_user)).to eq expected_points_for_another_winner
      end
    end

    context 'when the given user was not a winner' do
      it 'evaluates the given block' do
        unknown_user = FactoryGirl.create(:user)

        expect(table.payed_points(unknown_user) { 'unknown' }).to eq 'unknown'
      end
    end
  end
end
