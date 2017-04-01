require 'spec_helper'

describe PlaysCreator do
  let(:plays_creator) { PlaysCreator.for(table) }

  describe '#create_play' do
    context 'when no user is given' do
      let(:table) { FactoryGirl.create(:table) }

      it 'raises an error' do
        expect { plays_creator.create_play(players: []) }.to raise_error ArgumentError
      end
    end

    context 'when no players are given' do
      let(:table) { FactoryGirl.create(:table) }

      it 'raises an error' do
        expect { plays_creator.create_play(user: 'a user') }.to raise_error ArgumentError
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
                    expect { plays_creator.create_play(user: user, players: players) }.to raise_error PlayWithDuplicatedPlayer
                  end
                end

                context 'when the user selects different players' do
                  let(:players) { [river.players.sample, boca.players.sample] }

                  context 'when the user does not bet the table' do
                    it 'creates a new play for the given user with the given players without bet base coins' do
                      initial_amount_of_coins = user.coins

                      plays_creator.create_play(user: user, players: players)
                      play = Play.last

                      expect(play.user).to eq user
                      expect(play.players).to have(2).items
                      expect(play.players).to match_array(players)
                      expect(play.bet_base_coins).to eq 0
                      expect(user.coins).to eq initial_amount_of_coins
                    end
                  end

                  context 'when the user bets the table' do
                    let(:bet) { true }

                    context 'when the given amount of coins is valid' do
                      before { table.update_attributes(entry_coins_cost: user.coins) }

                      context 'when the user has enough coins to play' do
                        it 'creates a new play for the given user with the given players and subtracts coins from his wallet' do
                          plays_creator.create_play(user: user, players: players, bet: bet)
                          play = Play.last

                          expect(play.user).to eq user
                          expect(play.players).to have(2).items
                          expect(play.players).to match_array(players)
                          expect(play.bet_base_coins).to eq 10
                          expect(user.coins).to eq 0
                        end
                      end

                      context 'when the user has not enough coins to play' do
                        before { table.update_attributes(entry_coins_cost: 10000) }

                        it 'raises an error and does not subtract coins from his wallet' do
                          initial_amount_of_coins = user.coins

                          expect { plays_creator.create_play(user: user, players: players, bet: bet) }.to raise_error UserDoesNotHaveEnoughCoins

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
                  expect { plays_creator.create_play(user: user, players: players) }.to raise_error PlayerDoesNotBelongToTable
                  expect(Play.count).to be 0
                end
              end
            end

            context 'when the user has already played in that table' do
              before { plays_creator.create_play(user: user, players: players) }
              let(:players) { river.players.sample(2) }

              it 'raises an error' do
                expect { plays_creator.create_play(user: user, players: players) }.to raise_error UserHasAlreadyPlayedInThisTable
              end
            end
          end

          context 'when the user selects 1 players' do
            let(:players) { [river.players.sample] }

            it 'raises an error' do
              expect { plays_creator.create_play(user: user, players: players) }.to raise_error CanNotPlayWithNumberOfPlayers
            end
          end

          context 'when the user selects 3 players' do
            let(:players) { river.players.sample(3) }

            it 'raises an error' do
              expect { plays_creator.create_play(user: user, players: players) }.to raise_error CanNotPlayWithNumberOfPlayers
            end
          end
        end
      end
    end
  end
end
