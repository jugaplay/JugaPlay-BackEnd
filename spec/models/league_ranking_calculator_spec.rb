require 'spec_helper'

describe LeagueRankingCalculator do
  let(:calculator) { LeagueRankingCalculator.new(now, table) }
  let(:table) { FactoryGirl.create(:table) }
  let(:now) { Time.now }

  describe 'when there are no league plays' do
    it 'does not create any league ranking' do
      expect { calculator.call }.not_to change { LeagueRanking.count }
    end
  end

  describe 'when there are three users playing league' do
    let(:first_user) { FactoryGirl.create(:user, :without_chips) }
    let(:second_user) { FactoryGirl.create(:user, :without_chips) }
    let(:third_user) { FactoryGirl.create(:user, :without_chips) }
    let(:fourth_user) { FactoryGirl.create(:user, :without_chips) }

    let!(:first_user_first_play) { FactoryGirl.create(:play, :league, user: first_user, table: table, points: first_user_first_play_points) }
    let!(:second_user_first_play) { FactoryGirl.create(:play, :league, user: second_user, table: table, points: second_user_first_play_points) }
    let!(:third_user_first_play) { FactoryGirl.create(:play, :league, user: third_user, table: table, points: third_user_first_play_points) }
    let!(:fourth_user_first_play) { FactoryGirl.create(:play, :league, user: fourth_user, table: table, points: fourth_user_first_play_points) }

    describe 'when there are is no league' do
      let(:first_user_first_play_points) { 10 }
      let(:second_user_first_play_points) { 10 }
      let(:third_user_first_play_points) { 10 }
      let(:fourth_user_first_play_points) { 10 }

      it 'does not create any league ranking' do
        expect { calculator.call }.not_to change { LeagueRanking.count }
      end
    end

    describe 'when there are is a league' do
      let!(:league) { FactoryGirl.create(:league, title: 'League 1', frequency_in_days: 7, periods: 2, starts_at: now.at_beginning_of_day, status: :opened) }
      let!(:next_league) { FactoryGirl.create(:league, title: 'League 2', status: :opened, frequency_in_days: 1, periods: 1, starts_at: league.starts_at + 14.day) }

      describe 'when all the users got the same score' do
        let(:first_user_first_play_points) { 10 }
        let(:second_user_first_play_points) { 10 }
        let(:third_user_first_play_points) { 10 }
        let(:fourth_user_first_play_points) { 8 }

        it 'creates three league rankings with same position in round 0 and starts the league' do
          expect { calculator.call }.to change { LeagueRanking.count }.by 4

          expect(league.reload).to be_playing

          first_user_ranking = LeagueRanking.find_by(user: first_user)
          expect(first_user_ranking).to be_playing
          expect(first_user_ranking.league).to eq league
          expect(first_user_ranking.user).to eq first_user
          expect(first_user_ranking.round).to eq 1
          expect(first_user_ranking.position).to eq 1
          expect(first_user_ranking.round_points).to eq 10
          expect(first_user_ranking.plays).to match_array [first_user_first_play]

          second_user_ranking = LeagueRanking.find_by(user: second_user)
          expect(second_user_ranking).to be_playing
          expect(second_user_ranking.league).to eq league
          expect(second_user_ranking.user).to eq second_user
          expect(second_user_ranking.round).to eq 1
          expect(second_user_ranking.position).to eq 1
          expect(second_user_ranking.round_points).to eq 10
          expect(second_user_ranking.plays).to match_array [second_user_first_play]

          third_user_ranking = LeagueRanking.find_by(user: third_user)
          expect(third_user_ranking).to be_playing
          expect(third_user_ranking.league).to eq league
          expect(third_user_ranking.user).to eq third_user
          expect(third_user_ranking.round).to eq 1
          expect(third_user_ranking.position).to eq 1
          expect(third_user_ranking.round_points).to eq 10
          expect(third_user_ranking.plays).to match_array [third_user_first_play]

          fourth_user_ranking = LeagueRanking.find_by(user: fourth_user)
          expect(fourth_user_ranking).to be_playing
          expect(fourth_user_ranking.league).to eq league
          expect(fourth_user_ranking.user).to eq fourth_user
          expect(fourth_user_ranking.round).to eq 1
          expect(fourth_user_ranking.position).to eq 4
          expect(fourth_user_ranking.round_points).to eq 8
          expect(fourth_user_ranking.plays).to match_array [fourth_user_first_play]
        end

        describe 'when all the users play again the next day and score different points' do
          let(:second_table) { FactoryGirl.create(:table) }
          let(:second_calculator) { LeagueRankingCalculator.new(now + 1.day, second_table) }
          let!(:first_user_second_play) { FactoryGirl.create(:play, :league, user: first_user, table: second_table, points: 15) }
          let!(:second_user_second_play) { FactoryGirl.create(:play, :league, user: second_user, table: second_table, points: 10) }
          let!(:third_user_second_play) { FactoryGirl.create(:play, :league, user: third_user, table: second_table, points: 5) }

          before { calculator.call }

          it 'updates the existing league rankings' do
            expect { second_calculator.call }.not_to change { LeagueRanking.count }

            expect(league.reload).to be_playing

            first_user_ranking = LeagueRanking.find_by(user: first_user)
            expect(first_user_ranking).to be_playing
            expect(first_user_ranking.league).to eq league
            expect(first_user_ranking.user).to eq first_user
            expect(first_user_ranking.round).to eq 1
            expect(first_user_ranking.position).to eq 1
            expect(first_user_ranking.round_points).to eq 25
            expect(first_user_ranking.plays).to match_array [first_user_first_play, first_user_second_play]

            second_user_ranking = LeagueRanking.find_by(user: second_user)
            expect(second_user_ranking).to be_playing
            expect(second_user_ranking.league).to eq league
            expect(second_user_ranking.user).to eq second_user
            expect(second_user_ranking.round).to eq 1
            expect(second_user_ranking.position).to eq 2
            expect(second_user_ranking.round_points).to eq 20
            expect(second_user_ranking.plays).to match_array [second_user_first_play, second_user_second_play]

            third_user_ranking = LeagueRanking.find_by(user: third_user)
            expect(third_user_ranking).to be_playing
            expect(third_user_ranking.league).to eq league
            expect(third_user_ranking.user).to eq third_user
            expect(third_user_ranking.round).to eq 1
            expect(third_user_ranking.position).to eq 3
            expect(third_user_ranking.round_points).to eq 15
            expect(third_user_ranking.plays).to match_array [third_user_first_play, third_user_second_play]

            fourth_user_ranking = LeagueRanking.find_by(user: fourth_user)
            expect(fourth_user_ranking).to be_playing
            expect(fourth_user_ranking.league).to eq league
            expect(fourth_user_ranking.user).to eq fourth_user
            expect(fourth_user_ranking.round).to eq 1
            expect(fourth_user_ranking.position).to eq 4
            expect(fourth_user_ranking.round_points).to eq 8
            expect(fourth_user_ranking.plays).to match_array [fourth_user_first_play]
          end

          describe 'when all the users play again two days after and score some points' do
            let(:third_table) { FactoryGirl.create(:table) }
            let(:third_calculator) { LeagueRankingCalculator.new(now + 2.day, third_table) }
            let!(:first_user_third_play) { FactoryGirl.create(:play, :league, user: first_user, table: third_table, points: 10.5) }
            let!(:second_user_third_play) { FactoryGirl.create(:play, :league, user: second_user, table: third_table, points: 15.5) }
            let!(:third_user_third_play) { FactoryGirl.create(:play, :league, user: third_user, table: third_table, points: 10.5) }

            before { second_calculator.call }

            it 'updates the existing league rankings' do
              expect { third_calculator.call }.not_to change { LeagueRanking.count }

              expect(league.reload).to be_playing

              first_user_ranking = LeagueRanking.find_by(user: first_user)
              expect(first_user_ranking).to be_playing
              expect(first_user_ranking.league).to eq league
              expect(first_user_ranking.user).to eq first_user
              expect(first_user_ranking.round).to eq 1
              expect(first_user_ranking.position).to eq 1
              expect(first_user_ranking.round_points).to eq 25.5
              expect(first_user_ranking.plays).to match_array [first_user_first_play, first_user_second_play, first_user_third_play]

              second_user_ranking = LeagueRanking.find_by(user: second_user)
              expect(second_user_ranking).to be_playing
              expect(second_user_ranking.league).to eq league
              expect(second_user_ranking.user).to eq second_user
              expect(second_user_ranking.round).to eq 1
              expect(second_user_ranking.position).to eq 1
              expect(second_user_ranking.round_points).to eq 25.5
              expect(second_user_ranking.plays).to match_array [second_user_first_play, second_user_second_play, second_user_third_play]

              third_user_ranking = LeagueRanking.find_by(user: third_user)
              expect(third_user_ranking).to be_playing
              expect(third_user_ranking.league).to eq league
              expect(third_user_ranking.user).to eq third_user
              expect(third_user_ranking.round).to eq 1
              expect(third_user_ranking.position).to eq 3
              expect(third_user_ranking.round_points).to eq 20.5
              expect(third_user_ranking.plays).to match_array [third_user_first_play, third_user_second_play, third_user_third_play]

              fourth_user_ranking = LeagueRanking.find_by(user: fourth_user)
              expect(fourth_user_ranking).to be_playing
              expect(fourth_user_ranking.league).to eq league
              expect(fourth_user_ranking.user).to eq fourth_user
              expect(fourth_user_ranking.round).to eq 1
              expect(fourth_user_ranking.position).to eq 4
              expect(fourth_user_ranking.round_points).to eq 8
              expect(fourth_user_ranking.plays).to match_array [fourth_user_first_play]
            end

            describe 'when all the users play again 8 days after and score different points' do
              let(:fourth_table) { FactoryGirl.create(:table) }
              let(:fourth_calculator) { LeagueRankingCalculator.new(now + 8.day, fourth_table) }
              let!(:first_user_fourth_play) { FactoryGirl.create(:play, :league, user: first_user, table: fourth_table, points: 300) }
              let!(:second_user_fourth_play) { FactoryGirl.create(:play, :league, user: second_user, table: fourth_table, points: 200) }
              let!(:third_user_fourth_play) { FactoryGirl.create(:play, :league, user: third_user, table: fourth_table, points: 100) }

              before { third_calculator.call }

              it 'ends the last round and open a new one creating new league rankings' do
                expect { fourth_calculator.call }.to change { LeagueRanking.count }.by 4

                expect(league.reload).to be_playing
                first_user_rankings = LeagueRanking.where(user: first_user).order(round: :asc)
                second_user_rankings = LeagueRanking.where(user: second_user).order(round: :asc)
                third_user_rankings = LeagueRanking.where(user: third_user).order(round: :asc)
                fourth_user_rankings = LeagueRanking.where(user: fourth_user).order(round: :asc)

                expect(first_user_rankings.first).to be_ended
                expect(first_user_rankings.first.league).to eq league
                expect(first_user_rankings.first.user).to eq first_user
                expect(first_user_rankings.first.round).to eq 1
                expect(first_user_rankings.first.position).to eq 1
                expect(first_user_rankings.first.movement).to eq 0
                expect(first_user_rankings.first.round_points).to eq 25.5
                expect(first_user_rankings.first.total_points).to eq 25.5
                expect(first_user_rankings.first.plays).to match_array [first_user_first_play, first_user_second_play, first_user_third_play]

                expect(first_user_rankings.second).to be_playing
                expect(first_user_rankings.second.league).to eq league
                expect(first_user_rankings.second.user).to eq first_user
                expect(first_user_rankings.second.round).to eq 2
                expect(first_user_rankings.second.position).to eq 1
                expect(first_user_rankings.second.movement).to eq 0
                expect(first_user_rankings.second.round_points).to eq 300
                expect(first_user_rankings.second.total_points).to eq 325.5
                expect(first_user_rankings.second.plays).to match_array [first_user_fourth_play]

                expect(second_user_rankings.first).to be_ended
                expect(second_user_rankings.first.league).to eq league
                expect(second_user_rankings.first.user).to eq second_user
                expect(second_user_rankings.first.round).to eq 1
                expect(second_user_rankings.first.position).to eq 1
                expect(second_user_rankings.first.movement).to eq 0
                expect(second_user_rankings.first.round_points).to eq 25.5
                expect(second_user_rankings.first.total_points).to eq 25.5
                expect(second_user_rankings.first.plays).to match_array [second_user_first_play, second_user_second_play, second_user_third_play]

                expect(second_user_rankings.second).to be_playing
                expect(second_user_rankings.second.league).to eq league
                expect(second_user_rankings.second.user).to eq second_user
                expect(second_user_rankings.second.round).to eq 2
                expect(second_user_rankings.second.position).to eq 2
                expect(second_user_rankings.second.movement).to eq 1
                expect(second_user_rankings.second.round_points).to eq 200
                expect(second_user_rankings.second.total_points).to eq 225.5
                expect(second_user_rankings.second.plays).to match_array [second_user_fourth_play]

                expect(third_user_rankings.first).to be_ended
                expect(third_user_rankings.first.league).to eq league
                expect(third_user_rankings.first.user).to eq third_user
                expect(third_user_rankings.first.round).to eq 1
                expect(third_user_rankings.first.position).to eq 3
                expect(third_user_rankings.first.movement).to eq 0
                expect(third_user_rankings.first.round_points).to eq 20.5
                expect(third_user_rankings.first.total_points).to eq 20.5
                expect(third_user_rankings.first.plays).to match_array [third_user_first_play, third_user_second_play, third_user_third_play]

                expect(third_user_rankings.second).to be_playing
                expect(third_user_rankings.second.league).to eq league
                expect(third_user_rankings.second.user).to eq third_user
                expect(third_user_rankings.second.round).to eq 2
                expect(third_user_rankings.second.position).to eq 3
                expect(third_user_rankings.second.movement).to eq 0
                expect(third_user_rankings.second.round_points).to eq 100
                expect(third_user_rankings.second.total_points).to eq 120.5
                expect(third_user_rankings.second.plays).to match_array [third_user_fourth_play]

                expect(fourth_user_rankings.first).to be_ended
                expect(fourth_user_rankings.first.league).to eq league
                expect(fourth_user_rankings.first.user).to eq fourth_user
                expect(fourth_user_rankings.first.round).to eq 1
                expect(fourth_user_rankings.first.position).to eq 4
                expect(fourth_user_rankings.first.movement).to eq 0
                expect(fourth_user_rankings.first.round_points).to eq 8
                expect(fourth_user_rankings.first.total_points).to eq 8
                expect(fourth_user_rankings.first.plays).to match_array [fourth_user_first_play]

                expect(fourth_user_rankings.second).to be_playing
                expect(fourth_user_rankings.second.league).to eq league
                expect(fourth_user_rankings.second.user).to eq fourth_user
                expect(fourth_user_rankings.second.round).to eq 2
                expect(fourth_user_rankings.second.position).to eq 4
                expect(fourth_user_rankings.second.movement).to eq 0
                expect(fourth_user_rankings.second.round_points).to eq 0
                expect(fourth_user_rankings.second.total_points).to eq 8
                expect(fourth_user_rankings.second.plays).to match_array []
              end

              describe 'when all the users play again 16 days after and score different points' do
                let(:fifth_table) { FactoryGirl.create(:table) }
                let(:fifth_calculator) { LeagueRankingCalculator.new(now + 14.day, fifth_table) }
                let!(:first_user_fifth_play) { FactoryGirl.create(:play, :league, user: first_user, table: fifth_table, points: 1) }
                let!(:second_user_fifth_play) { FactoryGirl.create(:play, :league, user: second_user, table: fifth_table, points: 2) }
                let!(:third_user_fifth_play) { FactoryGirl.create(:play, :league, user: third_user, table: fifth_table, points: 3) }

                before { fourth_calculator.call }

                it 'closes the last league and deal prizes' do
                  league.update_attributes!(prizes: [99.chips, 1.chips])

                  fifth_calculator.call

                  expect(league.reload).to be_closed
                  expect(first_user.reload.chips).to eq 99.chips
                  expect(second_user.reload.chips).to eq 1.chips
                  expect(third_user.reload.chips).to eq 0.chips
                end

                it 'starts the next league one creating new league rankings' do
                  expect { fifth_calculator.call }.to change { LeagueRanking.count }.by 3

                  expect(next_league.reload).to be_playing

                  first_user_ranking = LeagueRanking.find_by(user: first_user, league: next_league)
                  expect(first_user_ranking).to be_playing
                  expect(first_user_ranking.league).to eq next_league
                  expect(first_user_ranking.user).to eq first_user
                  expect(first_user_ranking.round).to eq 1
                  expect(first_user_ranking.position).to eq 3
                  expect(first_user_ranking.movement).to eq 0
                  expect(first_user_ranking.round_points).to eq 1
                  expect(first_user_ranking.total_points).to eq 1
                  expect(first_user_ranking.plays).to match_array [first_user_fifth_play]

                  second_user_ranking = LeagueRanking.find_by(user: second_user, league: next_league)
                  expect(second_user_ranking).to be_playing
                  expect(second_user_ranking.league).to eq next_league
                  expect(second_user_ranking.user).to eq second_user
                  expect(second_user_ranking.round).to eq 1
                  expect(second_user_ranking.position).to eq 2
                  expect(second_user_ranking.movement).to eq 0
                  expect(second_user_ranking.round_points).to eq 2
                  expect(second_user_ranking.total_points).to eq 2
                  expect(second_user_ranking.plays).to match_array [second_user_fifth_play]

                  third_user_ranking = LeagueRanking.find_by(user: third_user, league: next_league)
                  expect(third_user_ranking).to be_playing
                  expect(third_user_ranking.league).to eq next_league
                  expect(third_user_ranking.user).to eq third_user
                  expect(third_user_ranking.round).to eq 1
                  expect(third_user_ranking.position).to eq 1
                  expect(third_user_ranking.movement).to eq 0
                  expect(third_user_ranking.round_points).to eq 3
                  expect(third_user_ranking.total_points).to eq 3
                  expect(third_user_ranking.plays).to match_array [third_user_fifth_play]
                end
              end
            end
          end
        end
      end
    end
  end
end
