require 'spec_helper'

describe TableCloser do
  let(:table_closer) { TableCloser.new(table) }
  let(:plays_creator) { PlaysCreator.for(table) }

  describe 'for public tables' do
    context 'when only one table is being calculated' do
      let(:tournament) { table.tournament }
      let(:table) { FactoryGirl.create(:table, number_of_players: 1, table_rules: table_rules, points_for_winners: [200, 100], coins_for_winners: [50, 20]) }
      let(:table_rules) { FactoryGirl.create(:table_rules, scored_goals: points_for_goal, right_passes: points_for_passes) }

      context 'when there is just one user playing' do
        let(:user) { FactoryGirl.create(:user, :without_coins) }

        context 'when the table pays 2 points for each goal' do
          let(:points_for_passes) { 0 }
          let(:points_for_goal) { 2 }

          context 'when the user plays with one player' do
            let(:match) { table.matches.last }
            let(:player) { match.local_team.players.last }
            let!(:player_stats) { FactoryGirl.create(:player_stats, player: player, match: match, scored_goals: player_goals) }

            before do
              plays_creator.create_play(user: user, players: [player])
              create_empty_stats_for_all table.matches
              table.start_closing!
            end

            context 'when the user plays for a player that does not score any goal' do
              let(:player_goals) { 0 }

              it 'closes the table, assigns 0 points to that play and places the user in the first position' do
                table_closer.call
                play = PlaysHistory.new.made_by(user).in_table(table).last

                expect(table).to be_closed
                expect(play.points).to eq 0
                expect(play.position).to eq 1
                expect(play.earned_coins).to eq 50
                expect(user.reload.coins).to eq 50
                expect(table.table_rankings).to have(1).item
              end

              context 'when the user has no current ranking' do
                it 'creates a tournament ranking for the user and assigns 200 points' do
                  table_closer.call

                  expect(user.ranking_on_tournament(tournament).points).to eq 200
                end
              end

              context 'when the user has a ranking' do
                let!(:ranking) { FactoryGirl.create(:ranking, tournament: tournament, user: user, points: 100) }

                it 'updates the current ranking adding 200 points' do
                  table_closer.call

                  expect(ranking.reload.points).to eq 300
                end
              end
            end

            context 'when the user plays for a player that scores 3 goals' do
              let(:player_goals) { 3 }

              it 'closes the table, assigns 6 points to that play and places the user in the first position' do
                table_closer.call
                play = PlaysHistory.new.made_by(user).in_table(table).last

                expect(table).to be_closed
                expect(play.points).to eq 6
                expect(play.position).to eq 1
                expect(play.earned_coins).to eq 50
                expect(user.reload.coins).to eq 50
                expect(table.table_rankings).to have(1).item
              end

              context 'when the user has no current ranking' do
                it 'creates a ranking on the tournament and assigns points for the winners' do
                  table_closer.call

                  expect(user.ranking_on_tournament(tournament).points).to eq 200
                end
              end

              context 'when the user has a ranking' do
                let!(:ranking) { FactoryGirl.create(:ranking, tournament: tournament, user: user, points: 100) }

                it 'updates the current ranking adding 200 points' do
                  table_closer.call

                  expect(ranking.reload.points).to eq 300
                end
              end
            end

            context 'when there are no stats for that player' do
              let!(:player_stats) { nil }

              it 'raises an error and does not assign points' do
                play = PlaysHistory.new.made_by(user).in_table(table).last
                play.players.each { |player| PlayerStats.where(player: player).delete_all }

                expect{ table_closer.call }.to raise_error MissingPlayerStats, "Missing required stats for #{player.name} for match #{match.title}"
                play = PlaysHistory.new.made_by(user).in_table(table).last

                expect(play.points).to be_nil
                expect(play.position).to eq 'N/A'
                expect(play.earned_coins).to eq 'N/A'
                expect(table.table_rankings).to be_empty
              end
            end
          end
        end
      end

      context 'when there are two users playing' do
        let(:first_user) { FactoryGirl.create(:user) }
        let(:second_user) { FactoryGirl.create(:user) }

        context 'when the first user plays for a player that scores 3 goals and 2 passes' do
          let(:last_match) { table.matches.last }
          let(:player_of_the_first_user) { last_match.local_team.players.last }
          let!(:first_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_first_user, match: last_match, scored_goals: 3, right_passes: 2) }

          before { plays_creator.create_play(user: first_user, players: [player_of_the_first_user]) }

          context 'when the second user plays for a player that scores 1 goals and 5 passes' do
            let(:first_match) { table.matches.first }
            let(:player_of_the_second_user) { first_match.visitor_team.players.first }
            let!(:second_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_second_user, match: first_match, scored_goals: 1, right_passes: 5) }

            before do
              plays_creator.create_play(user: second_user, players: [player_of_the_second_user])
              create_empty_stats_for_all table.matches
              table.start_closing!
            end

            context 'when the table pays 1 point for each goal and .5 for each pass' do
              let(:points_for_goal) { 1 }
              let(:points_for_passes) { 0.5 }

              it 'closes the table and updates the total points for each user' do
                table_closer.call

                first_user_play = PlaysHistory.new.made_by(first_user).in_table(table).last
                second_user_play = PlaysHistory.new.made_by(second_user).in_table(table).last

                expect(table).to be_closed
                expect(first_user.reload.coins).to eq 80
                expect(first_user_play.points).to eq 4
                expect(first_user_play.position).to eq 1
                expect(first_user_play.earned_coins).to eq 50
                expect(second_user.reload.coins).to eq 50
                expect(second_user_play.points).to eq 3.5
                expect(second_user_play.position).to eq 2
                expect(second_user_play.earned_coins).to eq 20
                expect(table.table_rankings).to have(2).items
              end
            end

            context 'when the table pays 0.1 point for each goal and .5 for each pass' do
              let(:points_for_goal) { 0.1 }
              let(:points_for_passes) { 0.5 }

              it 'closes the table and updates the total points for each user' do
                table_closer.call

                first_user_play = PlaysHistory.new.made_by(first_user).in_table(table).last
                second_user_play = PlaysHistory.new.made_by(second_user).in_table(table).last

                expect(table).to be_closed
                expect(first_user.reload.coins).to eq 50
                expect(first_user_play.points).to eq 1.3
                expect(first_user_play.position).to eq 2
                expect(first_user_play.earned_coins).to eq 20
                expect(second_user.reload.coins).to eq 80
                expect(second_user_play.points).to eq 2.6
                expect(second_user_play.position).to eq 1
                expect(second_user_play.earned_coins).to eq 50
                expect(table.table_rankings).to have(2).items
              end

              context 'when the first user has bet a multiplier by 3' do
                before { PlaysHistory.new.made_by(first_user).in_table(table).last.multiply_by!(3) }

                it 'closes the table and updates the total points for each user' do
                  table_closer.call

                  first_user_play = PlaysHistory.new.made_by(first_user).in_table(table).last
                  second_user_play = PlaysHistory.new.made_by(second_user).in_table(table).last

                  expect(table).to be_closed
                  expect(first_user.reload.coins).to eq 90
                  expect(first_user_play.points).to eq 1.3
                  expect(first_user_play.position).to eq 2
                  expect(first_user_play.earned_coins).to eq 60
                  expect(second_user.reload.coins).to eq 80
                  expect(second_user_play.points).to eq 2.6
                  expect(second_user_play.position).to eq 1
                  expect(second_user_play.earned_coins).to eq 50
                  expect(table.table_rankings).to have(2).items
                end
              end
            end
          end
        end
      end
    end

    context 'when 2 tables are being calculated, where each table has 2 matches and one of them is share by both' do
      let(:tournament) { FactoryGirl.create(:tournament) }
      let(:first_table_plays_creator) { PlaysCreator.for(first_table) }
      let(:second_table_plays_creator) { PlaysCreator.for(second_table) }
      let(:first_table_closer) { TableCloser.new(first_table) }
      let(:second_table_closer) { TableCloser.new(second_table) }

      let(:shared_match) { FactoryGirl.create(:match, tournament: tournament) }
      let(:first_table_match) { FactoryGirl.create(:match, tournament: tournament) }
      let(:second_table_match) { FactoryGirl.create(:match, tournament: tournament) }
      let(:first_table) { FactoryGirl.create(:table, matches: [first_table_match, shared_match], number_of_players: 1, table_rules: FactoryGirl.create(:table_rules, scored_goals: 1), points_for_winners: [200, 100], coins_for_winners: [50, 20], tournament: tournament) }
      let(:second_table) { FactoryGirl.create(:table, matches: [second_table_match, shared_match], number_of_players: 1, table_rules: FactoryGirl.create(:table_rules, scored_goals: 1), points_for_winners: [200, 100], coins_for_winners: [50, 20], tournament: tournament) }

      context 'when one user bets for a player of the first table match, and other user bets for a player of the shared match in both tables' do
        let(:first_user) { FactoryGirl.create(:user) }
        let(:second_user) { FactoryGirl.create(:user) }
        let(:player_of_the_first_user) { first_table_match.local_team.players.last }
        let(:player_of_the_second_user) { shared_match.visitor_team.players.first }
        let!(:first_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_first_user, match: first_table_match, scored_goals: 3) }
        let!(:second_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_second_user, match: shared_match, scored_goals: 2) }

        before do
          first_table_plays_creator.create_play(user: first_user, players: [player_of_the_first_user])
          first_table_plays_creator.create_play(user: second_user, players: [player_of_the_second_user])
          second_table_plays_creator.create_play(user: second_user, players: [player_of_the_second_user])
          create_empty_stats_for_all first_table.matches
          create_empty_stats_for_all second_table.matches
          first_table.start_closing!
          second_table.start_closing!
        end

        it 'closes both tables and updates the total points for each user' do
          first_table_closer.call
          first_user_first_table_play = PlaysHistory.new.made_by(first_user).in_table(first_table).last
          second_user_first_table_play = PlaysHistory.new.made_by(second_user).in_table(first_table).last

          expect(first_table).to be_closed
          expect(first_user.reload.coins).to eq 80
          expect(first_user_first_table_play.points).to eq 3
          expect(first_user_first_table_play.position).to eq 1
          expect(first_user_first_table_play.earned_coins).to eq 50
          expect(second_user.reload.coins).to eq 50
          expect(second_user_first_table_play.points).to eq 2
          expect(second_user_first_table_play.position).to eq 2
          expect(second_user_first_table_play.earned_coins).to eq 20
          expect(first_table.table_rankings).to have(2).items

          second_table_closer.call
          first_user_second_table_play = PlaysHistory.new.made_by(first_user).in_table(second_table).last
          second_user_second_table_play = PlaysHistory.new.made_by(second_user).in_table(second_table).last

          expect(second_table).to be_closed
          expect(first_user.reload.coins).to eq 80
          expect(first_user_second_table_play).to be_nil
          expect(second_user.reload.coins).to eq 100
          expect(second_user_second_table_play.points).to eq 2
          expect(second_user_second_table_play.position).to eq 1
          expect(second_user_second_table_play.earned_coins).to eq 50
          expect(second_table.table_rankings).to have(1).item
        end
      end
    end
  end

  describe 'for private tables' do
    context 'when only one table is being calculated' do
      let(:tournament) { table.tournament }
      let(:table) { FactoryGirl.create(:table, number_of_players: 1, table_rules: table_rules, group: group, entry_coins_cost: 99, points_for_winners: []) }
      let(:table_rules) { FactoryGirl.create(:table_rules, scored_goals: points_for_goal, right_passes: points_for_passes) }
      let(:group) { FactoryGirl.create(:group) }

      context 'when there is just one user playing' do
        let(:user) { FactoryGirl.create(:user, :with_coins, coins: 99) }

        before { group.update_attributes!(users: [user]) }

        context 'when the table pays 2 points for each goal' do
          let(:points_for_passes) { 0 }
          let(:points_for_goal) { 2 }

          context 'when the user plays with one player' do
            let(:match) { table.matches.last }
            let(:player) { match.local_team.players.last }
            let!(:player_stats) { FactoryGirl.create(:player_stats, player: player, match: match, scored_goals: player_goals) }

            before do
              plays_creator.create_play(user: user, players: [player])
              create_empty_stats_for_all table.matches
              table.start_closing!
            end

            context 'when the user plays for a player that does not score any goal' do
              let(:player_goals) { 0 }

              it 'closes the table, assigns 0 points to that play and places the user in the first position' do
                table_closer.call
                play = PlaysHistory.new.made_by(user).in_table(table).last

                expect(table).to be_closed
                expect(play.points).to eq 0
                expect(play.position).to eq 1
                expect(play.earned_coins).to eq 99
                expect(user.reload.coins).to eq 99
                expect(table.table_rankings).to have(1).item
              end

              context 'when the user has no current ranking' do
                it 'does not create a tournament ranking for the user' do
                  table_closer.call

                  expect(user.ranking_on_tournament(tournament)).to be_nil
                end
              end

              context 'when the user has a ranking' do
                let!(:ranking) { FactoryGirl.create(:ranking, tournament: tournament, user: user, points: 100) }

                it 'does not update the current ranking' do
                  table_closer.call

                  expect(ranking.reload.points).to eq 100
                end
              end
            end

            context 'when the user plays for a player that scores 3 goals' do
              let(:player_goals) { 3 }

              it 'closes the table, assigns 6 points to that play and places the user in the first position' do
                table_closer.call
                play = PlaysHistory.new.made_by(user).in_table(table).last

                expect(table).to be_closed
                expect(play.points).to eq 6
                expect(play.position).to eq 1
                expect(play.earned_coins).to eq 99
                expect(user.reload.coins).to eq 99
                expect(table.table_rankings).to have(1).item
              end

              context 'when the user has no current ranking' do
                it 'does not create a tournament ranking for the user' do
                  table_closer.call

                  expect(user.ranking_on_tournament(tournament)).to be_nil
                end
              end

              context 'when the user has a ranking' do
                let!(:ranking) { FactoryGirl.create(:ranking, tournament: tournament, user: user, points: 100) }

                it 'does not update the current ranking' do
                  table_closer.call

                  expect(ranking.reload.points).to eq 100
                end
              end
            end

            context 'when there are no stats for that player' do
              let!(:player_stats) { nil }

              it 'raises an error and does not assign points' do
                play = PlaysHistory.new.made_by(user).in_table(table).last
                play.players.each { |player| PlayerStats.where(player: player).delete_all }

                expect{ table_closer.call }.to raise_error MissingPlayerStats, "Missing required stats for #{player.name} for match #{match.title}"
                play = PlaysHistory.new.made_by(user).in_table(table).last

                expect(play.points).to be_nil
                expect(play.position).to eq 'N/A'
                expect(play.earned_coins).to eq 'N/A'
                expect(table.table_rankings).to be_empty
              end
            end
          end
        end
      end

      context 'when there are two users playing' do
        let(:first_user) { FactoryGirl.create(:user, :with_coins, coins: 99) }
        let(:second_user) { FactoryGirl.create(:user, :with_coins, coins: 99) }

        context 'when those users belong to the group' do
          before { group.update_attributes!(users: [first_user, second_user]) }

          context 'when the first user plays for a player that scores 3 goals and 2 passes' do
            let(:last_match) { table.matches.last }
            let(:player_of_the_first_user) { last_match.local_team.players.last }
            let!(:first_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_first_user, match: last_match, scored_goals: 3, right_passes: 2) }

            before { plays_creator.create_play(user: first_user, players: [player_of_the_first_user]) }

            context 'when the second user plays for a player that scores 1 goals and 5 passes' do
              let(:first_match) { table.matches.first }
              let(:player_of_the_second_user) { table.matches.first.visitor_team.players.first }
              let!(:second_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_second_user, match: first_match, scored_goals: 1, right_passes: 5) }

              before do
                plays_creator.create_play(user: second_user, players: [player_of_the_second_user])
                create_empty_stats_for_all table.matches
                table.start_closing!
              end

              context 'when the table pays 1 point for each goal and .5 for each pass' do
                let(:points_for_goal) { 1 }
                let(:points_for_passes) { 0.5 }

                it 'closes the table, gives the pot to the first user and updates the points of each play' do
                  table_closer.call

                  first_user_play = PlaysHistory.new.made_by(first_user).in_table(table).last
                  second_user_play = PlaysHistory.new.made_by(second_user).in_table(table).last

                  expect(table).to be_closed
                  expect(first_user.reload.coins).to eq (99 * 2)
                  expect(first_user_play.points).to eq 4
                  expect(first_user_play.position).to eq 1
                  expect(first_user_play.earned_coins).to eq (99 * 2)
                  expect(second_user.reload.coins).to eq 0
                  expect(second_user_play.points).to eq 3.5
                  expect(second_user_play.position).to eq 2
                  expect(second_user_play.earned_coins).to eq 0
                  expect(table.table_rankings).to have(2).items
                end
              end

              context 'when the table pays 0.1 point for each goal and .5 for each pass' do
                let(:points_for_goal) { 0.1 }
                let(:points_for_passes) { 0.5 }

                it 'closes the table, gives the pot to the second user and updates the points of each play' do
                  table_closer.call

                  first_user_play = PlaysHistory.new.made_by(first_user).in_table(table).last
                  second_user_play = PlaysHistory.new.made_by(second_user).in_table(table).last

                  expect(table).to be_closed
                  expect(first_user.reload.coins).to eq 0
                  expect(first_user_play.points).to eq 1.3
                  expect(first_user_play.position).to eq 2
                  expect(first_user_play.earned_coins).to eq 0
                  expect(second_user.reload.coins).to eq (99 * 2)
                  expect(second_user_play.points).to eq 2.6
                  expect(second_user_play.position).to eq 1
                  expect(second_user_play.earned_coins).to eq (99 * 2)
                  expect(table.table_rankings).to have(2).items
                end
              end
            end
          end
        end

        context 'when those users do not belong to the group' do
          let(:points_for_goal) { 100 }
          let(:points_for_passes) { 0 }
          let(:match) { table.matches.last }
          let(:player) { match.local_team.players.last }
          let!(:player_stats) { FactoryGirl.create(:player_stats, player: player, match: match, scored_goals: 10) }

          it 'closes the table and does not give coins to any user' do
            create_empty_stats_for_all table.matches
            first_user_old_amount_of_coins = first_user.coins
            second_user_old_amount_of_coins = second_user.coins
            table.start_closing!

            table_closer.call

            expect(table).to be_closed
            expect(table.table_rankings).to be_empty
            expect(first_user.reload.coins).to eq first_user_old_amount_of_coins
            expect(second_user.reload.coins).to eq second_user_old_amount_of_coins
            expect(table.table_rankings).to be_empty
          end
        end
      end
    end

    context 'when 2 tables are being calculated, where each table has 2 matches and one of them is share by both' do
      let(:tournament) { FactoryGirl.create(:tournament) }
      let(:first_table_plays_creator) { PlaysCreator.for(first_table) }
      let(:second_table_plays_creator) { PlaysCreator.for(second_table) }
      let(:first_table_closer) { TableCloser.new(first_table) }
      let(:second_table_closer) { TableCloser.new(second_table) }

      let(:shared_match) { FactoryGirl.create(:match, tournament: tournament) }
      let(:first_table_match) { FactoryGirl.create(:match, tournament: tournament) }
      let(:second_table_match) { FactoryGirl.create(:match, tournament: tournament) }
      let(:first_table) { FactoryGirl.create(:table, group: group, matches: [first_table_match, shared_match], number_of_players: 1, table_rules: FactoryGirl.create(:table_rules, scored_goals: 1), entry_coins_cost: 10, points_for_winners: [], tournament: tournament) }
      let(:second_table) { FactoryGirl.create(:table, group: group, matches: [second_table_match, shared_match], number_of_players: 1, table_rules: FactoryGirl.create(:table_rules, scored_goals: 1), entry_coins_cost: 10, points_for_winners: [], tournament: tournament) }

      context 'when one user bets for a player of the first table match, and other user bets for a player of the shared match in both tables' do
        let(:group) { FactoryGirl.create(:group, users: [first_user, second_user]) }
        let(:first_user) { FactoryGirl.create(:user, :with_coins, coins: 1000) }
        let(:second_user) { FactoryGirl.create(:user, :with_coins, coins: 1000) }
        let(:player_of_the_first_user) { first_table_match.local_team.players.last }
        let(:player_of_the_second_user) { shared_match.visitor_team.players.first }
        let!(:first_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_first_user, match: first_table_match, scored_goals: 3) }
        let!(:second_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_second_user, match: shared_match, scored_goals: 2) }

        before do
          first_table_plays_creator.create_play(user: first_user, players: [player_of_the_first_user])
          first_table_plays_creator.create_play(user: second_user, players: [player_of_the_second_user])
          second_table_plays_creator.create_play(user: second_user, players: [player_of_the_second_user])
          create_empty_stats_for_all first_table.matches
          create_empty_stats_for_all second_table.matches
          first_table.start_closing!
          second_table.start_closing!
        end

        it 'closes both tables and updates the total points for each user' do
          first_table_closer.call
          first_user_first_table_play = PlaysHistory.new.made_by(first_user).in_table(first_table).last
          second_user_first_table_play = PlaysHistory.new.made_by(second_user).in_table(first_table).last

          expect(first_table).to be_closed
          expect(first_user.reload.coins).to eq 1010
          expect(first_user_first_table_play.points).to eq 3
          expect(first_user_first_table_play.position).to eq 1
          expect(first_user_first_table_play.earned_coins).to eq 20
          expect(second_user.reload.coins).to eq 980
          expect(second_user_first_table_play.points).to eq 2
          expect(second_user_first_table_play.position).to eq 2
          expect(second_user_first_table_play.earned_coins).to eq 0
          expect(first_table.table_rankings).to have(2).items

          second_table_closer.call
          first_user_second_table_play = PlaysHistory.new.made_by(first_user).in_table(second_table).last
          second_user_second_table_play = PlaysHistory.new.made_by(second_user).in_table(second_table).last

          expect(second_table).to be_closed
          expect(first_user.reload.coins).to eq 1010
          expect(first_user_second_table_play).to be_nil
          expect(second_user.reload.coins).to eq 990
          expect(second_user_second_table_play.points).to eq 2
          expect(second_user_second_table_play.position).to eq 1
          expect(second_user_second_table_play.earned_coins).to eq 10
          expect(second_table.table_rankings).to have(1).items
        end
      end
    end
  end
end
