require 'spec_helper'

describe TableWinnersCalculator do
  let(:calculator) { TableWinnersCalculator.for(table) }
  
  context 'when a table is given' do
    let(:tournament) { FactoryGirl.create(:tournament) }

    context 'for a public table' do
      let!(:table) { FactoryGirl.create(:table, tournament: tournament, points_for_winners: points_for_winners) }
      let!(:another_table) { FactoryGirl.create(:table, tournament: tournament, points_for_winners: [1000, 500, 100, 50, 10]) }

      context 'when there are 3 users' do
        let!(:first_user) { FactoryGirl.create(:user) }
        let!(:second_user) { FactoryGirl.create(:user) }
        let!(:third_user) { FactoryGirl.create(:user) }

        context 'when the users have not played in other tables before' do
          context 'when all the users have made different scores' do
            let!(:first_user_play) { FactoryGirl.create(:play, user: first_user, table: table, points: first_user_points) }
            let!(:second_user_play) { FactoryGirl.create(:play, user: second_user, table: table, points: second_user_points) }
            let!(:third_user_play) { FactoryGirl.create(:play, user: third_user, table: table, points: third_user_points) }

            context 'when all the scores are positive' do
              let(:first_user_points) { 4 }
              let(:second_user_points) { 5 }
              let(:third_user_points) { 6 }

              context 'when the table gives points to one user' do
                let(:points_for_winners) { [100] }

                it 'returns the user with higher score on the table' do
                  winners = calculator.call

                  expect(winners).to have(1).item
                  expect(winners.first).to eq third_user
                end
              end

              context 'when the table gives points to two users' do
                let(:points_for_winners) { [200, 100] }

                it 'returns the two users with highest scores on the table' do
                  winners = calculator.call

                  expect(winners).to have(2).items
                  expect(winners.first).to eq third_user
                  expect(winners.second).to eq second_user
                end
              end

              context 'when the table gives points to four users' do
                let(:points_for_winners) { [400, 300, 200, 100] }

                it 'returns the three users with highest scores on the table' do
                  winners = calculator.call

                  expect(winners).to have(3).items
                  expect(winners.first).to eq third_user
                  expect(winners.second).to eq second_user
                  expect(winners.third).to eq first_user
                end
              end
            end

            context 'when some scores are negative' do
              let(:first_user_points) { 4 }
              let(:second_user_points) { -5 }
              let(:third_user_points) { -1 }

              context 'when the table gives points to one user' do
                let(:points_for_winners) { [100] }

                it 'returns the user with higher score on the table' do
                  winners = calculator.call

                  expect(winners).to have(1).item
                  expect(winners.first).to eq first_user
                end
              end

              context 'when the table gives points to two users' do
                let(:points_for_winners) { [200, 100] }

                it 'returns the two users with highest scores on the table' do
                  winners = calculator.call

                  expect(winners).to have(2).items
                  expect(winners.first).to eq first_user
                  expect(winners.second).to eq third_user
                end
              end

              context 'when the table gives points to four users' do
                let(:points_for_winners) { [400, 300, 200, 100] }

                it 'returns the three users with highest scores on the table' do
                  winners = calculator.call

                  expect(winners).to have(3).items
                  expect(winners.first).to eq first_user
                  expect(winners.second).to eq third_user
                  expect(winners.third).to eq second_user
                end
              end
            end
          end

          context 'when all the users have made same scores' do
            let!(:first_user_play) { FactoryGirl.create(:play, user: first_user, table: table, points: 6) }
            let!(:second_user_play) { FactoryGirl.create(:play, user: second_user, table: table, points: 6) }
            let!(:third_user_play) { FactoryGirl.create(:play, user: third_user, table: table, points: 6) }

            context 'when the table gives points to one user' do
              let(:points_for_winners) { [100] }

              it 'returns the oldest user' do
                winners = calculator.call

                expect(winners).to have(1).item
                expect(winners.first).to eq first_user
              end
            end

            context 'when the table gives points to two users' do
              let(:points_for_winners) { [200, 100] }

              it 'returns the two oldest users' do
                winners = calculator.call

                expect(winners).to have(2).items
                expect(winners.first).to eq first_user
                expect(winners.second).to eq second_user
              end
            end

            context 'when the table gives points to four users' do
              let(:points_for_winners) { [400, 300, 200, 100] }

              it 'returns the three oldest users' do
                winners = calculator.call

                expect(winners).to have(3).items
                expect(winners.first).to eq first_user
                expect(winners.second).to eq second_user
                expect(winners.third).to eq third_user
              end
            end
          end
        end

        context 'when the users have played before' do
          let!(:first_user_first_play) { FactoryGirl.create(:play, user: first_user, table: another_table, points: 1) }
          let!(:second_user_first_play) { FactoryGirl.create(:play, user: second_user, table: another_table, points: 10) }
          let!(:third_user_first_play) { FactoryGirl.create(:play, user: third_user, table: another_table, points: 1) }

          before(:each) do
            users = [second_user, first_user, third_user]
            RankingPointsUpdater.new(tournament: tournament, users: users, points_for_winners: another_table.points_for_winners).call
            RankingSorter.new(tournament).call
          end

          context 'when all the users have made different scores' do
            let!(:first_user_second_play) { FactoryGirl.create(:play, user: first_user, table: table, points: 4) }
            let!(:second_user_second_play) { FactoryGirl.create(:play, user: second_user, table: table, points: 5) }
            let!(:third_user_second_play) { FactoryGirl.create(:play, user: third_user, table: table, points: 6) }

            context 'when the table gives points to two users' do
              let(:points_for_winners) { [200, 100] }

              it 'returns the two users with highest scores on the table' do
                winners = calculator.call

                expect(winners).to have(2).items
                expect(winners.first).to eq third_user
                expect(winners.second).to eq second_user
              end
            end
          end

          context 'when all the users have made same scores' do
            let!(:first_user_second_play) { FactoryGirl.create(:play, user: first_user, table: table, points: 6) }
            let!(:second_user_second_play) { FactoryGirl.create(:play, user: second_user, table: table, points: 6) }
            let!(:third_user_second_play) { FactoryGirl.create(:play, user: third_user, table: table, points: 6) }

            context 'when the table gives points to two users' do
              let(:points_for_winners) { [200, 100] }

              it 'returns the two users with highest ranking on the tournament follow by the oldest users' do
                winners = calculator.call

                expect(winners).to have(2).items
                expect(winners.first).to eq second_user
                expect(winners.second).to eq first_user
              end
            end
          end
        end

        context 'when some users have played before' do
          let!(:first_user_first_play) { FactoryGirl.create(:play, user: first_user, table: another_table, points: 1) }
          let!(:second_user_first_play) { FactoryGirl.create(:play, user: second_user, table: another_table, points: 10) }

          before(:each) do
            users = [second_user, first_user]
            RankingPointsUpdater.new(tournament: tournament, users: users, points_for_winners: another_table.points_for_winners).call
            RankingSorter.new(tournament).call
          end

          context 'when the users have made different scores' do
            let!(:first_user_second_play) { FactoryGirl.create(:play, user: first_user, table: table, points: 6) }
            let!(:second_user_second_play) { FactoryGirl.create(:play, user: second_user, table: table, points: 6) }
            let!(:third_user_second_play) { FactoryGirl.create(:play, user: third_user, table: table, points: 10) }

            context 'when the table gives points to two users' do
              let(:points_for_winners) { [200, 100, 10] }

              context 'when there are no other rankings' do
                it 'returns the two users with highest ranking on the tournament follow by the oldest users' do
                  winners = calculator.call

                  expect(winners).to have(3).items
                  expect(winners.first).to eq third_user
                  expect(winners.second).to eq second_user
                  expect(winners.third).to eq first_user
                end
              end

              context 'when the users have rankings for another tournament' do
                let(:another_tournament) { FactoryGirl.create(:tournament) }
                let!(:first_user_another_ranking) { FactoryGirl.create(:ranking, tournament: another_tournament, user: first_user, points: 100) }
                let!(:second_user_another_ranking) { FactoryGirl.create(:ranking, tournament: another_tournament, user: second_user, points: 100) }
                let!(:third_user_another_ranking) { FactoryGirl.create(:ranking, tournament: another_tournament, user: third_user, points: 1000) }

                it 'does not take into account the other rankings and returns the two users with highest ranking on the tournament follow by the oldest users' do
                  winners = calculator.call

                  expect(winners).to have(3).items
                  expect(winners.first).to eq third_user
                  expect(winners.second).to eq second_user
                  expect(winners.third).to eq first_user
                end
              end

              context 'when there are more users with rankings for another tournament' do
                let(:another_tournament) { FactoryGirl.create(:tournament) }
                let!(:first_user_another_ranking) { FactoryGirl.create(:ranking, tournament: another_tournament, user: first_user, points: 100) }
                let!(:second_user_another_ranking) { FactoryGirl.create(:ranking, tournament: another_tournament, user: second_user, points: 100) }
                let!(:third_user_another_ranking) { FactoryGirl.create(:ranking, tournament: another_tournament, user: third_user, points: 1000) }
                let!(:fourth_user_another_ranking) { FactoryGirl.create(:ranking, tournament: another_tournament, user: FactoryGirl.create(:user), points: 500) }

                it 'does not take into account the other rankings and returns the two users with highest ranking on the tournament follow by the oldest users' do
                  winners = calculator.call

                  expect(winners).to have(3).items
                  expect(winners.first).to eq third_user
                  expect(winners.second).to eq second_user
                  expect(winners.third).to eq first_user
                end
              end
            end
          end
        end
      end
    end

    context 'for a private table' do
      let(:group) { FactoryGirl.create(:group) }
      let(:table) { FactoryGirl.create(:table, tournament: tournament, points_for_winners: [], group: group) }
      let(:first_user) { FactoryGirl.create(:user) }
      let(:second_user) { FactoryGirl.create(:user) }
      let(:third_user) { FactoryGirl.create(:user) }

      context 'when all the users have made different scores' do
        let!(:first_user_play) { FactoryGirl.create(:play, user: first_user, table: table, points: first_user_points) }
        let!(:second_user_play) { FactoryGirl.create(:play, user: second_user, table: table, points: second_user_points) }
        let!(:third_user_play) { FactoryGirl.create(:play, user: third_user, table: table, points: third_user_points) }

        context 'when all the scores are positive' do
          let(:first_user_points) { 4 }
          let(:second_user_points) { 5 }
          let(:third_user_points) { 6 }

          it 'returns the user with highest score on the table follow by the oldest users' do
            winners = calculator.call

            expect(winners).to have(3).items
            expect(winners.first).to eq third_user
            expect(winners.second).to eq second_user
            expect(winners.third).to eq first_user
          end
        end

        context 'when some scores are negative' do
          let(:first_user_points) { 4 }
          let(:second_user_points) { -5 }
          let(:third_user_points) { -1 }

          it 'returns the user with highest score on the table follow by the oldest users' do
            winners = calculator.call

            expect(winners).to have(3).items
            expect(winners.first).to eq first_user
            expect(winners.second).to eq third_user
            expect(winners.third).to eq second_user
          end
        end
      end

      context 'when all the users have made same scores' do
        let!(:first_user_play) { FactoryGirl.create(:play, user: first_user, table: table, points: 6) }
        let!(:second_user_play) { FactoryGirl.create(:play, user: second_user, table: table, points: 6) }
        let!(:third_user_play) { FactoryGirl.create(:play, user: third_user, table: table, points: 6) }

        it 'returns the user with highest score on the table follow by the oldest users' do
          winners = calculator.call

          expect(winners).to have(3).items
          expect(winners.first).to eq first_user
          expect(winners.second).to eq second_user
          expect(winners.third).to eq third_user
        end
      end
    end
  end

  context 'when no table is given' do
    let(:table) { nil }

    it 'raises an error' do
      expect { calculator.call }.to raise_error ArgumentError, 'A table must be given'
    end
  end
end