require 'spec_helper'

describe PlayerPointsCalculator do
  let(:calculator) { PlayerPointsCalculator.new }

  describe '#call' do
    let(:table) { FactoryGirl.create(:table, table_rules: table_rules) }
    let(:match) { table.matches.first }

    context 'when table rules and players stats are populated' do
      let(:table_rules) { FactoryGirl.create(:table_rules, scored_goals: points_for_goal, right_passes: points_for_pass) }

      context 'with one player stats' do
        let(:player) { match.players.first }
        let!(:player_stats) { FactoryGirl.create(:player_stats, scored_goals: scored_goals, right_passes: scored_passes, match: match, player: player) }

        context 'when the table pays 2 points for each goal and .1 for each pass' do
          let(:points_for_goal) { 2 }
          let(:points_for_pass) { 0.1 }

          context 'when a player has scored 3 goal' do
            let(:scored_goals) { 3 }

            context 'when the player has not done any passes' do
              let(:scored_passes) { 0 }

              it 'returns 6 points' do
                points = calculator.call(table, player)

                expect(points).to eq 6
              end
            end

            context 'when the player has done 8 passes' do
              let(:scored_passes) { 8 }

              it 'returns 6.8 points' do
                points = calculator.call(table, player)

                expect(points).to eq 6.8
              end
            end
          end
        end

        context 'when the table pays 0.675 points for each goal and 0.314 for each pass' do
          let(:points_for_goal) { 0.675 }
          let(:points_for_pass) { 0.314 }

          context 'when the player has scored 1 goal and no passes' do
            let(:scored_goals) { 1 }
            let(:scored_passes) { 0 }

            it 'rounds the total' do
              points = calculator.call(table, player)

              expect(points).to eq 0.68
            end
          end

          context 'when the player has scored 1 pass and no goals' do
            let(:scored_goals) { 0 }
            let(:scored_passes) { 1 }

            it 'rounds the total' do
              points = calculator.call(table, player)

              expect(points).to eq 0.31
            end
          end
        end

        context 'when the table pays -1 points for each goal and 0.5 for each pass' do
          let(:points_for_goal) { -1 }
          let(:points_for_pass) { 0.5 }

          context 'when the player has scored 1 goal and 1 pass' do
            let(:scored_goals) { 1 }
            let(:scored_passes) { 1 }

            it 'returns -0.5 points' do
              points = calculator.call(table, player)

              expect(points).to eq -0.5
            end
          end
        end
      end

      context 'with two player stats' do
        let(:first_player) { match.players.first }
        let(:second_player) { match.players.second }
        let!(:first_player_stats) { FactoryGirl.create(:player_stats, scored_goals: first_player_goals, right_passes: first_player_passes, match: match, player: first_player) }
        let!(:second_player_stats) { FactoryGirl.create(:player_stats, scored_goals: second_player_goals, right_passes: second_player_passes, match: match, player: second_player) }

        context 'when the table pays .8 points for each goal and .1 for each pass' do
          let(:points_for_goal) { 0.8 }
          let(:points_for_pass) { 0.1 }

          context 'when the first player has scored 1 goal and 1 pass' do
            let(:first_player_goals) { 1 }
            let(:first_player_passes) { 1 }

            context 'when the second player has not scored any goal nor passes' do
              let(:second_player_goals) { 0 }
              let(:second_player_passes) { 0 }

              it 'returns .9 points for the first player and 0 points for the second player' do
                first_player_points = calculator.call(table, first_player)
                second_player_points = calculator.call(table, second_player)

                expect(first_player_points).to eq 0.9
                expect(second_player_points).to eq 0
              end
            end

            context 'when the second player has scored 2 goals and 4 passes' do
              let(:second_player_goals) { 2 }
              let(:second_player_passes) { 4 }

              it 'returns .9 points for the first player and 2 points for the second player' do
                first_player_points = calculator.call(table, first_player)
                second_player_points = calculator.call(table, second_player)

                expect(first_player_points).to eq 0.9
                expect(second_player_points).to eq 2
              end
            end
          end
        end
      end
    end
  end
end
