require 'spec_helper'

describe Croupier do
  let(:croupier) { Croupier.for(table) }
  let(:table) { FactoryGirl.create(:table) }

  describe '#play' do
    context 'when no user is given' do
      it 'raises an error' do
        expect { croupier.play(players: []) }.to raise_error ArgumentError
      end
    end

    context 'when no players are given' do
      it 'raises an error' do
        expect { croupier.play(user: 'a user') }.to raise_error ArgumentError
      end
    end

    context 'when a user and players are populated' do
      let(:tournament) { FactoryGirl.create(:tournament) }
      let(:table) { FactoryGirl.create(:table, matches: matches, number_of_players: number_of_players, tournament: tournament) }
      let(:match) { FactoryGirl.create(:match, title: '20 PTS River - Boca', local_team: river, visitor_team: boca, tournament: tournament) }
      let(:river) { FactoryGirl.create(:team, :river) }
      let(:boca) { FactoryGirl.create(:team, :boca) }
      let(:user) { FactoryGirl.create(:user) }

      context 'when the table has one match' do
        let(:matches) { [match] }

        context 'when the table has 2 number of players' do
          let(:number_of_players) { 2 }

          context 'when the user selects 2 players' do
            context 'when the user has not already played in that table' do
              context 'when the user selects players of the available teams' do
                context 'when the user selects the same player twice' do
                  let(:player) { river.players.sample }
                  let(:players) { [player, player] }

                  it 'raises an error' do
                    expect { croupier.play(user: user, players: players) }.to raise_error PlayWithDuplicatedPlayer
                  end
                end

                context 'when the user selects different players' do
                  let(:players) { [river.players.sample, boca.players.sample] }

                  context 'when the user does not bet the table' do
                    it 'creates a new play for the given user with the given players without bet coins' do
                      initial_amount_of_coins = user.coins

                      croupier.play(user: user, players: players)
                      play = Play.last

                      expect(play.user).to eq user
                      expect(play.players).to have(2).items
                      expect(play.players).to match_array(players)
                      expect(play.bet_coins).to eq 0
                      expect(user.coins).to eq initial_amount_of_coins
                    end
                  end

                  context 'when the user bets the table' do
                    let(:bet) { true }

                    context 'when the given amount of coins is valid' do
                      before { table.update_attributes(entry_coins_cost: user.coins) }

                      context 'when the user has enough coins to play' do
                        it 'creates a new play for the given user with the given players and subtracts coins from his wallet' do
                          croupier.play(user: user, players: players, bet: bet)
                          play = Play.last

                          expect(play.user).to eq user
                          expect(play.players).to have(2).items
                          expect(play.players).to match_array(players)
                          expect(play.bet_coins).to eq 10
                          expect(user.coins).to eq 0
                        end
                      end

                      context 'when the user has not enough coins to play' do
                        before { table.update_attributes(entry_coins_cost: 10000) }

                        it 'raises an error and does not subtract coins from his wallet' do
                          initial_amount_of_coins = user.coins

                          expect { croupier.play(user: user, players: players, bet: bet) }.to raise_error UserDoesNotHaveEnoughCoins

                          expect(user.reload.coins).to eq initial_amount_of_coins
                        end
                      end
                    end
                  end
                end
              end

              context 'when the user selects players of non available teams' do
                let(:another_player) { FactoryGirl.create(:player) }
                let(:players) { [river.players.sample, another_player] }

                it 'raises an error' do
                  expect { croupier.play(user: user, players: players) }.to raise_error PlayerDoesNotBelongToTable
                  expect(Play.count).to be 0
                end
              end
            end

            context 'when the user has already played in that table' do
              before { croupier.play(user: user, players: players) }
              let(:players) { river.players.sample(2) }

              it 'raises an error' do
                expect { croupier.play(user: user, players: players) }.to raise_error UserHasAlreadyPlayedInThisTable
              end
            end
          end

          context 'when the user selects 1 players' do
            let(:players) { [river.players.sample] }

            it 'raises an error' do
              expect { croupier.play(user: user, players: players) }.to raise_error CanNotPlayWithNumberOfPlayers
            end
          end

          context 'when the user selects 3 players' do
            let(:players) { river.players.sample(3) }

            it 'raises an error' do
              expect { croupier.play(user: user, players: players) }.to raise_error CanNotPlayWithNumberOfPlayers
            end
          end
        end
      end
    end
  end

  describe '#assign_scores' do
    let(:tournament) { table.tournament }
    let(:table_rules) { FactoryGirl.create(:table_rules, scored_goals: points_for_goal, right_passes: points_for_passes) }
    let(:points_for_passes) { 0 }

    describe 'for public tables' do
      let(:table) { FactoryGirl.create(:table, number_of_players: 1, table_rules: table_rules, points_for_winners: [200, 100], coins_for_winners: [50, 20]) }

      context 'when there is just one user playing' do
        let(:user) { FactoryGirl.create(:user, :without_coins) }

        context 'when the table pays 2 points for each goal' do
          let(:points_for_goal) { 2 }

          context 'when the user plays with one player' do
            let(:player) { table.matches.last.local_team.players.last }
            let(:player_stats) { FactoryGirl.create(:player_stats, player: player, scored_goals: player_goals) }

            before { croupier.play(user: user, players: [player]) }

            context 'when the user plays for a player that does not score any goal' do
              let(:player_goals) { 0 }

              it 'closes the table, assigns 0 points to that play and places the user in the first position' do
                croupier.assign_scores(players_stats: [player_stats])
                play = PlaysHistory.new.made_by(user).of_table(table).last

                expect(table).to be_closed
                expect(play.points).to eq 0
                expect(table.winners).to have(1).item
                expect(table.winners.first.user).to eq user
                expect(table.winners.first.position).to eq 1
              end

              it 'gives 50 coins to the user' do
                croupier.assign_scores(players_stats: [player_stats])
                prize = UserPrize.last

                expect(user.reload.coins).to eq 50
                expect(UserPrize.count).to eq 1
                expect(prize.coins).to eq 50
                expect(prize.user).to eq user
                expect(prize.table).to eq table
              end

              context 'when the user has no current ranking' do
                it 'creates a tournament ranking for the user and assigns 200 points' do
                  croupier.assign_scores(players_stats: [player_stats])

                  expect(user.ranking_on_tournament(tournament).points).to eq 200
                end
              end

              context 'when the user has a ranking' do
                let!(:ranking) { FactoryGirl.create(:ranking, tournament: tournament, user: user, points: 100) }

                it 'updates the current ranking adding 200 points' do
                  croupier.assign_scores(players_stats: [player_stats])

                  expect(ranking.reload.points).to eq 300
                end
              end
            end

            context 'when the user plays for a player that scores 3 goals' do
              let(:player_goals) { 3 }

              it 'closes the table, assigns 6 points to that play and places the user in the first position' do
                croupier.assign_scores(players_stats: [player_stats])
                play = PlaysHistory.new.made_by(user).of_table(table).last

                expect(table).to be_closed
                expect(play.points).to eq 6
                expect(table.winners).to have(1).item
                expect(table.winners.first.user).to eq user
                expect(table.winners.first.position).to eq 1
              end

              it 'gives 50 coins to the user' do
                croupier.assign_scores(players_stats: [player_stats])
                prize = UserPrize.last

                expect(user.reload.coins).to eq 50
                expect(UserPrize.count).to eq 1
                expect(prize.coins).to eq 50
                expect(prize.user).to eq user
                expect(prize.table).to eq table
              end

              context 'when the user has no current ranking' do
                it 'creates a ranking on the tournament and assigns points for the winners' do
                  croupier.assign_scores(players_stats: [player_stats])

                  expect(user.ranking_on_tournament(tournament).points).to eq 200
                end
              end

              context 'when the user has a ranking' do
                let!(:ranking) { FactoryGirl.create(:ranking, tournament: tournament, user: user, points: 100) }

                it 'updates the current ranking adding 200 points' do
                  croupier.assign_scores(players_stats: [player_stats])

                  expect(ranking.reload.points).to eq 300
                end
              end
            end

            context 'when there are no stats for that player' do
              it 'raises an error and does not assign points' do
                expect{ croupier.assign_scores(players_stats: []) }.to raise_error MissingPlayerStats
                play = PlaysHistory.new.made_by(user).of_table(table).last

                expect(play.points).to be_nil
              end

              it 'raises an error and does not give coins to the user' do
                expect{ croupier.assign_scores(players_stats: []) }.to raise_error MissingPlayerStats

                expect(user.reload.coins).to eq 0
                expect(UserPrize.count).to eq 0
              end

              context 'when the user has no current ranking' do
                it 'does not create a ranking on the tournament' do
                  expect{ croupier.assign_scores(players_stats: []) }.to raise_error MissingPlayerStats

                  expect(user.ranking_on_tournament(tournament)).to be_nil
                end
              end

              context 'when the user has a ranking' do
                let!(:ranking) { FactoryGirl.create(:ranking, tournament: tournament, user: user, points: 100) }

                it 'does not update the current ranking' do
                  expect{ croupier.assign_scores(players_stats: []) }.to raise_error MissingPlayerStats

                  expect(ranking.reload.points).to eq 100
                end
              end
            end
          end
        end
      end

      context 'when there are two users playing' do
        let(:first_user) { FactoryGirl.create(:user) }
        let(:second_user) { FactoryGirl.create(:user) }

        context 'when the first user plays for a player that scores 3 goals and 2 passes' do
          let(:player_of_the_first_user) { table.matches.last.local_team.players.last }
          let(:first_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_first_user, scored_goals: 3, right_passes: 2) }

          before { croupier.play(user: first_user, players: [player_of_the_first_user]) }

          context 'when the second user plays for a player that scores 1 goals and 5 passes' do
            let(:player_of_the_second_user) { table.matches.first.visitor_team.players.first }
            let(:second_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_second_user, scored_goals: 1, right_passes: 5) }

            before { croupier.play(user: second_user, players: [player_of_the_second_user]) }

            context 'when the table pays 1 point for each goal and .5 for each pass' do
              let(:points_for_goal) { 1 }
              let(:points_for_passes) { 0.5 }

              it 'closes the table and updates the total points for each user' do
                croupier.assign_scores(players_stats: [first_player_stats, second_player_stats])

                first_user_play = PlaysHistory.new.made_by(first_user).of_table(table).last
                second_user_play = PlaysHistory.new.made_by(second_user).of_table(table).last

                expect(table).to be_closed
                expect(first_user_play.points).to eq 4
                expect(second_user_play.points).to eq 3.5
                expect(first_user.reload.coins).to eq 60
                expect(second_user.reload.coins).to eq 30

                expect(table.winners).to have(2).item
                expect(table.winners.first.user).to eq first_user
                expect(table.winners.first.position).to eq 1
                expect(table.winners.second.user).to eq second_user
                expect(table.winners.second.position).to eq 2
              end
            end

            context 'when the table pays 0.1 point for each goal and .5 for each pass' do
              let(:points_for_goal) { 0.1 }
              let(:points_for_passes) { 0.5 }

              it 'closes the table and updates the total points for each user' do
                croupier.assign_scores(players_stats: [first_player_stats, second_player_stats])

                first_user_play = PlaysHistory.new.made_by(first_user).of_table(table).last
                second_user_play = PlaysHistory.new.made_by(second_user).of_table(table).last

                expect(table).to be_closed
                expect(first_user_play.points).to eq 1.3
                expect(second_user_play.points).to eq 2.6
                expect(first_user.reload.coins).to eq 30
                expect(second_user.reload.coins).to eq 60

                expect(table.winners).to have(2).item
                expect(table.winners.first.user).to eq second_user
                expect(table.winners.first.position).to eq 1
                expect(table.winners.second.user).to eq first_user
                expect(table.winners.second.position).to eq 2
              end
            end
          end
        end
      end
    end

    describe 'for private tables' do
      let(:table) { FactoryGirl.create(:table, number_of_players: 1, table_rules: table_rules, group: group, entry_coins_cost: 99) }
      let(:group) { FactoryGirl.create(:group) }

      context 'when there is just one user playing' do
        let(:user) { FactoryGirl.create(:user, :with_coins, coins: 99) }

        before { group.update_attributes!(users: [user]) }

        context 'when the table pays 2 points for each goal' do
          let(:points_for_goal) { 2 }

          context 'when the user plays with one player' do
            let(:player) { table.matches.last.local_team.players.last }
            let(:player_stats) { FactoryGirl.create(:player_stats, player: player, scored_goals: player_goals) }

            before { croupier.play(user: user, players: [player]) }

            context 'when the user plays for a player that does not score any goal' do
              let(:player_goals) { 0 }

              it 'closes the table, assigns 0 points to that play and places the user in the first position' do
                croupier.assign_scores(players_stats: [player_stats])
                play = PlaysHistory.new.made_by(user).of_table(table).last

                expect(table).to be_closed
                expect(play.points).to eq 0
                expect(table.winners).to have(1).item
                expect(table.winners.first.user).to eq user
                expect(table.winners.first.position).to eq 1
              end

              it 'gives 99 coins to the user' do
                croupier.assign_scores(players_stats: [player_stats])
                prize = UserPrize.last

                expect(user.reload.coins).to eq 99
                expect(UserPrize.count).to eq 1
                expect(prize.coins).to eq 99
                expect(prize.user).to eq user
                expect(prize.table).to eq table
              end

              context 'when the user has no current ranking' do
                it 'does not create a tournament ranking for the user' do
                  croupier.assign_scores(players_stats: [player_stats])

                  expect(user.ranking_on_tournament(tournament)).to be_nil
                end
              end

              context 'when the user has a ranking' do
                let!(:ranking) { FactoryGirl.create(:ranking, tournament: tournament, user: user, points: 100) }

                it 'does not update the current ranking' do
                  croupier.assign_scores(players_stats: [player_stats])

                  expect(ranking.reload.points).to eq 100
                end
              end
            end

            context 'when the user plays for a player that scores 3 goals' do
              let(:player_goals) { 3 }

              it 'closes the table, assigns 6 points to that play and places the user in the first position' do
                croupier.assign_scores(players_stats: [player_stats])
                play = PlaysHistory.new.made_by(user).of_table(table).last

                expect(table).to be_closed
                expect(play.points).to eq 6
                expect(table.winners).to have(1).item
                expect(table.winners.first.user).to eq user
                expect(table.winners.first.position).to eq 1
              end

              it 'gives 99 coins to the user' do
                croupier.assign_scores(players_stats: [player_stats])
                prize = UserPrize.last

                expect(user.reload.coins).to eq 99
                expect(UserPrize.count).to eq 1
                expect(prize.coins).to eq 99
                expect(prize.user).to eq user
                expect(prize.table).to eq table
              end

              context 'when the user has no current ranking' do
                it 'does not create a tournament ranking for the user' do
                  croupier.assign_scores(players_stats: [player_stats])

                  expect(user.ranking_on_tournament(tournament)).to be_nil
                end
              end

              context 'when the user has a ranking' do
                let!(:ranking) { FactoryGirl.create(:ranking, tournament: tournament, user: user, points: 100) }

                it 'does not update the current ranking' do
                  croupier.assign_scores(players_stats: [player_stats])

                  expect(ranking.reload.points).to eq 100
                end
              end
            end

            context 'when there are no stats for that player' do
              it 'raises an error and does not assign points' do
                expect{ croupier.assign_scores(players_stats: []) }.to raise_error MissingPlayerStats
                play = PlaysHistory.new.made_by(user).of_table(table).last

                expect(play.points).to be_nil
              end

              it 'raises an error and does not give coins to the user' do
                expect{ croupier.assign_scores(players_stats: []) }.to raise_error MissingPlayerStats

                expect(user.reload.coins).to eq 0
                expect(UserPrize.count).to eq 0
              end

              context 'when the user has no current ranking' do
                it 'does not create a ranking on the tournament' do
                  expect{ croupier.assign_scores(players_stats: []) }.to raise_error MissingPlayerStats

                  expect(user.ranking_on_tournament(tournament)).to be_nil
                end
              end

              context 'when the user has a ranking' do
                let!(:ranking) { FactoryGirl.create(:ranking, tournament: tournament, user: user, points: 100) }

                it 'does not update the current ranking' do
                  expect{ croupier.assign_scores(players_stats: []) }.to raise_error MissingPlayerStats

                  expect(ranking.reload.points).to eq 100
                end
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
            let(:player_of_the_first_user) { table.matches.last.local_team.players.last }
            let(:first_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_first_user, scored_goals: 3, right_passes: 2) }

            before { croupier.play(user: first_user, players: [player_of_the_first_user]) }

            context 'when the second user plays for a player that scores 1 goals and 5 passes' do
              let(:player_of_the_second_user) { table.matches.first.visitor_team.players.first }
              let(:second_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_second_user, scored_goals: 1, right_passes: 5) }

              before { croupier.play(user: second_user, players: [player_of_the_second_user]) }

              context 'when the table pays 1 point for each goal and .5 for each pass' do
                let(:points_for_goal) { 1 }
                let(:points_for_passes) { 0.5 }

                it 'closes the table, gives the pot to the first user and updates the points of each play' do
                  croupier.assign_scores(players_stats: [first_player_stats, second_player_stats])

                  first_user_play = PlaysHistory.new.made_by(first_user).of_table(table).last
                  second_user_play = PlaysHistory.new.made_by(second_user).of_table(table).last

                  expect(table).to be_closed
                  expect(first_user_play.points).to eq 4
                  expect(second_user_play.points).to eq 3.5
                  expect(first_user.reload.coins).to eq(99 * 2)
                  expect(second_user.reload.coins).to eq 0

                  expect(table.winners).to have(2).item
                  expect(table.winners.first.user).to eq first_user
                  expect(table.winners.first.position).to eq 1
                  expect(table.winners.second.user).to eq second_user
                  expect(table.winners.second.position).to eq 2
                end
              end

              context 'when the table pays 0.1 point for each goal and .5 for each pass' do
                let(:points_for_goal) { 0.1 }
                let(:points_for_passes) { 0.5 }

                it 'closes the table, gives the pot to the second user and updates the points of each play' do
                  croupier.assign_scores(players_stats: [first_player_stats, second_player_stats])

                  first_user_play = PlaysHistory.new.made_by(first_user).of_table(table).last
                  second_user_play = PlaysHistory.new.made_by(second_user).of_table(table).last

                  expect(table).to be_closed
                  expect(first_user_play.points).to eq 1.3
                  expect(second_user_play.points).to eq 2.6
                  expect(second_user.reload.coins).to eq (99 * 2)
                  expect(first_user.reload.coins).to eq 0

                  expect(table.winners).to have(2).item
                  expect(table.winners.first.user).to eq second_user
                  expect(table.winners.first.position).to eq 1
                  expect(table.winners.second.user).to eq first_user
                  expect(table.winners.second.position).to eq 2
                end
              end
            end
          end
        end

        context 'when those users do not belong to the group' do
          let(:points_for_goal) { 100 }
          let(:player) { table.matches.last.local_team.players.last }
          let(:player_stats) { FactoryGirl.create(:player_stats, player: player, scored_goals: 10) }

          it 'closes the table and does not give coins to any user' do
            first_user_old_amount_of_coins = first_user.coins
            second_user_old_amount_of_coins = second_user.coins

            croupier.assign_scores(players_stats: [player_stats])

            expect(table).to be_closed
            expect(table.winners).to be_empty
            expect(first_user.reload.coins).to eq first_user_old_amount_of_coins
            expect(second_user.reload.coins).to eq second_user_old_amount_of_coins
            expect(table.winners).to be_empty
          end
        end
      end
    end
  end
end
