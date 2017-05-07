require 'spec_helper'

describe TableRankingCalculator do
  let(:tournament) { FactoryGirl.create(:tournament) }
  let(:calculator) { TableRankingCalculator.new(table) }

  context 'for a public table' do
    let!(:table) { FactoryGirl.create(:table, tournament: tournament, points_for_winners: points_for_winners) }
    let!(:another_table) { FactoryGirl.create(:table, tournament: tournament, points_for_winners: [1000, 500, 100, 50, 10]) }

    context 'when there are 3 users' do
      let!(:first_user) { FactoryGirl.create(:user) }
      let!(:second_user) { FactoryGirl.create(:user) }
      let!(:third_user) { FactoryGirl.create(:user) }

      context 'when the users have not played in other tables before' do
        let!(:first_user_play) { FactoryGirl.create(:play, user: first_user, table: table, points: first_user_points) }
        let!(:second_user_play) { FactoryGirl.create(:play, user: second_user, table: table, points: second_user_points) }
        let!(:third_user_play) { FactoryGirl.create(:play, user: third_user, table: table, points: third_user_points) }

        context 'when all the scores are positive' do
          let(:first_user_points) { 4 }
          let(:second_user_points) { 5 }
          let(:third_user_points) { 6 }

          context 'when the table does not give points for winners' do
            let(:points_for_winners) { [] }

            it 'creates rankings for all the users assigning the play points' do
              calculator.call

              table_rankings = table.table_rankings
              expect(table_rankings).to have(3).items

              expect(table_rankings.first.play).to eq third_user_play
              expect(table_rankings.first.points).to eq 6
              expect(table_rankings.first.position).to eq 1

              expect(table_rankings.second.play).to eq second_user_play
              expect(table_rankings.second.points).to eq 5
              expect(table_rankings.second.position).to eq 2

              expect(table_rankings.third.play).to eq first_user_play
              expect(table_rankings.third.points).to eq 4
              expect(table_rankings.third.position).to eq 3
            end
          end

          context 'when the table gives points to one user' do
            let(:points_for_winners) { [100] }

            xit 'creates rankings for all the users giving points to the first winner on the table' do
              calculator.call

              table_rankings = table.reload.table_rankings
              expect(table_rankings).to have(3).items

              expect(table_rankings.first.play).to eq third_user_play
              expect(table_rankings.first.points).to eq 100
              expect(table_rankings.first.position).to eq 1

              expect(table_rankings.second.play).to eq second_user_play
              expect(table_rankings.second.points).to eq 0
              expect(table_rankings.second.position).to eq 2

              expect(table_rankings.third.play).to eq first_user_play
              expect(table_rankings.third.points).to eq 0
              expect(table_rankings.third.position).to eq 3
            end
          end

          context 'when the table gives points to two users' do
            let(:points_for_winners) { [200, 100] }

            xit 'creates rankings for all the users giving points to the firsts two winners on the table' do
              calculator.call

              table_rankings = table.table_rankings
              expect(table_rankings).to have(3).items

              expect(table_rankings.first.play).to eq third_user_play
              expect(table_rankings.first.points).to eq 200
              expect(table_rankings.first.position).to eq 1

              expect(table_rankings.second.play).to eq second_user_play
              expect(table_rankings.second.points).to eq 100
              expect(table_rankings.second.position).to eq 2

              expect(table_rankings.third.play).to eq first_user_play
              expect(table_rankings.third.points).to eq 0
              expect(table_rankings.third.position).to eq 3
            end
          end

          context 'when the table gives points to four users' do
            let(:points_for_winners) { [400, 300, 200, 100] }

            xit 'creates rankings for all the users giving points to the all the players on the table' do
              calculator.call

              table_rankings = table.table_rankings
              expect(table_rankings).to have(3).items

              expect(table_rankings.first.play).to eq third_user_play
              expect(table_rankings.first.points).to eq 400
              expect(table_rankings.first.position).to eq 1

              expect(table_rankings.second.play).to eq second_user_play
              expect(table_rankings.second.points).to eq 300
              expect(table_rankings.second.position).to eq 2

              expect(table_rankings.third.play).to eq first_user_play
              expect(table_rankings.third.points).to eq 200
              expect(table_rankings.third.position).to eq 3
            end
          end
        end

        context 'when some scores are negative' do
          let(:first_user_points) { 4 }
          let(:second_user_points) { -5 }
          let(:third_user_points) { -1 }

          context 'when the table does not give points for winners' do
            let(:points_for_winners) { [] }

            it 'creates rankings for all the users assigning the play points' do
              calculator.call

              table_rankings = table.table_rankings
              expect(table_rankings).to have(3).items

              expect(table_rankings.first.play).to eq first_user_play
              expect(table_rankings.first.points).to eq 4
              expect(table_rankings.first.position).to eq 1

              expect(table_rankings.second.play).to eq third_user_play
              expect(table_rankings.second.points).to eq 0
              expect(table_rankings.second.position).to eq 2

              expect(table_rankings.third.play).to eq second_user_play
              expect(table_rankings.third.points).to eq 0
              expect(table_rankings.third.position).to eq 3
            end
          end

          context 'when the table gives points to one user' do
            let(:points_for_winners) { [100] }

            xit 'creates rankings for all the users giving points to the first winner on the table' do
              calculator.call

              table_rankings = table.table_rankings
              expect(table_rankings).to have(3).items

              expect(table_rankings.first.play).to eq first_user_play
              expect(table_rankings.first.points).to eq 100
              expect(table_rankings.first.position).to eq 1

              expect(table_rankings.second.play).to eq third_user_play
              expect(table_rankings.second.points).to eq 0
              expect(table_rankings.second.position).to eq 2

              expect(table_rankings.third.play).to eq second_user_play
              expect(table_rankings.third.points).to eq 0
              expect(table_rankings.third.position).to eq 3
            end
          end

          context 'when the table gives points to two users' do
            let(:points_for_winners) { [200, 100] }

            xit 'creates rankings for all the users giving points to the first two winners on the table' do
              calculator.call

              table_rankings = table.table_rankings
              expect(table_rankings).to have(3).items

              expect(table_rankings.first.play).to eq first_user_play
              expect(table_rankings.first.points).to eq 200
              expect(table_rankings.first.position).to eq 1

              expect(table_rankings.second.play).to eq third_user_play
              expect(table_rankings.second.points).to eq 100
              expect(table_rankings.second.position).to eq 2

              expect(table_rankings.third.play).to eq second_user_play
              expect(table_rankings.third.points).to eq 0
              expect(table_rankings.third.position).to eq 3
            end
          end

          context 'when the table gives points to four users' do
            let(:points_for_winners) { [400, 300, 200, 100] }

            xit 'creates rankings for all the users giving points to the all the players on the table' do
              calculator.call

              table_rankings = table.table_rankings
              expect(table_rankings).to have(3).items

              expect(table_rankings.first.play).to eq first_user_play
              expect(table_rankings.first.points).to eq 400
              expect(table_rankings.first.position).to eq 1

              expect(table_rankings.second.play).to eq third_user_play
              expect(table_rankings.second.points).to eq 300
              expect(table_rankings.second.position).to eq 2

              expect(table_rankings.third.play).to eq second_user_play
              expect(table_rankings.third.points).to eq 200
              expect(table_rankings.third.position).to eq 3
            end
          end
        end

        context 'when all the users have made same scores' do
          let(:first_user_points) { 6 }
          let(:second_user_points) { 6 }
          let(:third_user_points) { 6 }

          context 'when the table does not give points for winners' do
            let(:points_for_winners) { [] }

            it 'creates rankings for all the users assigning the play points' do
              calculator.call

              table_rankings = table.table_rankings
              expect(table_rankings).to have(3).items

              expect(table_rankings.first.play).to eq first_user_play
              expect(table_rankings.first.points).to eq 6
              expect(table_rankings.first.position).to eq 1

              expect(table_rankings.second.play).to eq second_user_play
              expect(table_rankings.second.points).to eq 6
              expect(table_rankings.second.position).to eq 1

              expect(table_rankings.third.play).to eq third_user_play
              expect(table_rankings.third.points).to eq 6
              expect(table_rankings.third.position).to eq 1
            end
          end

          context 'when the table gives points to one user' do
            let(:points_for_winners) { [100] }

            xit 'creates rankings for all the users giving points to the oldest user' do
              calculator.call

              table_rankings = table.table_rankings
              expect(table_rankings).to have(3).items

              expect(table_rankings.first.play).to eq first_user_play
              expect(table_rankings.first.points).to eq 100
              expect(table_rankings.first.position).to eq 1

              expect(table_rankings.second.play).to eq second_user_play
              expect(table_rankings.second.points).to eq 100
              expect(table_rankings.second.position).to eq 1

              expect(table_rankings.third.play).to eq third_user_play
              expect(table_rankings.third.points).to eq 100
              expect(table_rankings.third.position).to eq 1
            end
          end

          context 'when the table gives points to two users' do
            let(:points_for_winners) { [200, 100] }

            xit 'creates rankings for all the users giving points to the firsts two oldest users' do
              calculator.call

              table_rankings = table.table_rankings
              expect(table_rankings).to have(3).items

              expect(table_rankings.first.play).to eq first_user_play
              expect(table_rankings.first.points).to eq 200
              expect(table_rankings.first.position).to eq 1

              expect(table_rankings.second.play).to eq second_user_play
              expect(table_rankings.second.points).to eq 200
              expect(table_rankings.second.position).to eq 1

              expect(table_rankings.third.play).to eq third_user_play
              expect(table_rankings.third.points).to eq 200
              expect(table_rankings.third.position).to eq 1
            end
          end
        end

        context 'when some users have made same scores' do
          let(:first_user_points) { 6 }
          let(:second_user_points) { 6 }
          let(:third_user_points) { 4 }

          context 'when the table does not give points for winners' do
            let(:points_for_winners) { [] }

            it 'creates rankings for all the users assigning the play points' do
              calculator.call

              table_rankings = table.table_rankings
              expect(table_rankings).to have(3).items

              expect(table_rankings.first.play).to eq first_user_play
              expect(table_rankings.first.points).to eq 6
              expect(table_rankings.first.position).to eq 1

              expect(table_rankings.second.play).to eq second_user_play
              expect(table_rankings.second.points).to eq 6
              expect(table_rankings.second.position).to eq 1

              expect(table_rankings.third.play).to eq third_user_play
              expect(table_rankings.third.points).to eq 4
              expect(table_rankings.third.position).to eq 3
            end
          end

          context 'when the table gives points to one user' do
            let(:points_for_winners) { [100] }

            xit 'creates rankings for all the users giving points to the oldest user' do
              calculator.call

              table_rankings = table.table_rankings
              expect(table_rankings).to have(3).items

              expect(table_rankings.first.play).to eq first_user_play
              expect(table_rankings.first.points).to eq 100
              expect(table_rankings.first.position).to eq 1

              expect(table_rankings.second.play).to eq second_user_play
              expect(table_rankings.second.points).to eq 100
              expect(table_rankings.second.position).to eq 1

              expect(table_rankings.third.play).to eq third_user_play
              expect(table_rankings.third.points).to eq 0
              expect(table_rankings.third.position).to eq 3
            end
          end

          context 'when the table gives points to two users' do
            let(:points_for_winners) { [200, 100] }

            xit 'creates rankings for all the users giving points to the firsts two oldest users' do
              calculator.call

              table_rankings = table.table_rankings
              expect(table_rankings).to have(3).items

              expect(table_rankings.first.play).to eq first_user_play
              expect(table_rankings.first.points).to eq 200
              expect(table_rankings.first.position).to eq 1

              expect(table_rankings.second.play).to eq second_user_play
              expect(table_rankings.second.points).to eq 200
              expect(table_rankings.second.position).to eq 1

              expect(table_rankings.third.play).to eq third_user_play
              expect(table_rankings.third.points).to eq 0
              expect(table_rankings.third.position).to eq 3
            end
          end
        end
      end

      context 'when the users have played before' do
        let!(:first_user_first_play) { FactoryGirl.create(:play, user: first_user, table: another_table, points: 1) }
        let!(:second_user_first_play) { FactoryGirl.create(:play, user: second_user, table: another_table, points: 10) }
        let!(:third_user_first_play) { FactoryGirl.create(:play, user: third_user, table: another_table, points: 1) }

        before do
          TableRankingCalculator.new(another_table).call
          RankingPointsUpdater.new(another_table).call
          RankingSorter.new(tournament).call

          another_table_rankings = another_table.table_rankings
          expect(another_table_rankings).to have(3).items
          expect(another_table_rankings.first.play).to eq second_user_first_play
          expect(another_table_rankings.second.play).to eq first_user_first_play
          expect(another_table_rankings.third.play).to eq third_user_first_play
        end

        context 'when all the users have played in this table' do
          let!(:first_user_second_play) { FactoryGirl.create(:play, user: first_user, table: table, points: first_user_points) }
          let!(:second_user_second_play) { FactoryGirl.create(:play, user: second_user, table: table, points: second_user_points) }
          let!(:third_user_second_play) { FactoryGirl.create(:play, user: third_user, table: table, points: third_user_points) }

          context 'when all the scores are positive' do
            let(:first_user_points) { 4 }
            let(:second_user_points) { 5 }
            let(:third_user_points) { 6 }

            context 'when the table does not give points for winners' do
              let(:points_for_winners) { [] }

              it 'creates rankings for all the users assigning the play points' do
                calculator.call

                table_rankings = table.table_rankings
                expect(table_rankings).to have(3).items

                expect(table_rankings.first.play).to eq third_user_second_play
                expect(table_rankings.first.points).to eq 6
                expect(table_rankings.first.position).to eq 1

                expect(table_rankings.second.play).to eq second_user_second_play
                expect(table_rankings.second.points).to eq 5
                expect(table_rankings.second.position).to eq 2

                expect(table_rankings.third.play).to eq first_user_second_play
                expect(table_rankings.third.points).to eq 4
                expect(table_rankings.third.position).to eq 3
              end
            end

            context 'when the table gives points to two users' do
              let(:points_for_winners) { [200, 100] }

              xit 'creates rankings for all the users giving points to the firsts two winners on the table' do
                calculator.call

                table_rankings = table.table_rankings
                expect(table_rankings).to have(3).items

                expect(table_rankings.first.play).to eq third_user_second_play
                expect(table_rankings.first.points).to eq 200
                expect(table_rankings.first.position).to eq 1

                expect(table_rankings.second.play).to eq second_user_second_play
                expect(table_rankings.second.points).to eq 100
                expect(table_rankings.second.position).to eq 2

                expect(table_rankings.third.play).to eq first_user_second_play
                expect(table_rankings.third.points).to eq 0
                expect(table_rankings.third.position).to eq 3
              end
            end
          end

          context 'when all the users have made same scores' do
            let(:first_user_points) { 6 }
            let(:second_user_points) { 6 }
            let(:third_user_points) { 6 }

            context 'when the table does not give points for winners' do
              let(:points_for_winners) { [] }

              it 'creates rankings for all the users assigning the play points' do
                calculator.call

                table_rankings = table.table_rankings
                expect(table_rankings).to have(3).items

                expect(table_rankings.first.play).to eq first_user_second_play
                expect(table_rankings.first.points).to eq 6
                expect(table_rankings.first.position).to eq 1

                expect(table_rankings.second.play).to eq second_user_second_play
                expect(table_rankings.second.points).to eq 6
                expect(table_rankings.second.position).to eq 1

                expect(table_rankings.third.play).to eq third_user_second_play
                expect(table_rankings.third.points).to eq 6
                expect(table_rankings.third.position).to eq 1
              end
            end

            context 'when the table gives points to two users' do
              let(:points_for_winners) { [200, 100] }

              xit 'creates rankings for all the users giving points just to the users with highest ranking on the tournament followed by the oldest users' do
                calculator.call

                table_rankings = table.table_rankings
                expect(table_rankings).to have(3).items

                expect(table_rankings.first.play).to eq first_user_second_play
                expect(table_rankings.first.points).to eq 200
                expect(table_rankings.first.position).to eq 1

                expect(table_rankings.second.play).to eq second_user_second_play
                expect(table_rankings.second.points).to eq 200
                expect(table_rankings.second.position).to eq 1

                expect(table_rankings.third.play).to eq third_user_second_play
                expect(table_rankings.third.points).to eq 200
                expect(table_rankings.third.position).to eq 1
              end
            end
          end
        end
      end

      context 'when some users have played before' do
        let!(:first_user_first_play) { FactoryGirl.create(:play, user: first_user, table: another_table, points: 1) }
        let!(:second_user_first_play) { FactoryGirl.create(:play, user: second_user, table: another_table, points: 10) }

        before do
          TableRankingCalculator.new(another_table).call
          RankingPointsUpdater.new(another_table).call
          RankingSorter.new(tournament).call

          another_table_rankings = another_table.table_rankings
          expect(another_table_rankings).to have(2).items
          expect(another_table_rankings.first.play).to eq second_user_first_play
          expect(another_table_rankings.second.play).to eq first_user_first_play
        end

        context 'when all the users have played in this table' do
          let!(:first_user_second_play) { FactoryGirl.create(:play, user: first_user, table: table, points: 6) }
          let!(:second_user_second_play) { FactoryGirl.create(:play, user: second_user, table: table, points: 6) }
          let!(:third_user_second_play) { FactoryGirl.create(:play, user: third_user, table: table, points: 10) }

          context 'when the table does not give points for winners' do
            let(:points_for_winners) { [] }

            it 'creates rankings for all the users assigning the play points' do
              calculator.call

              table_rankings = table.table_rankings
              expect(table_rankings).to have(3).items

              expect(table_rankings.first.play).to eq third_user_second_play
              expect(table_rankings.first.points).to eq 10
              expect(table_rankings.first.position).to eq 1

              expect(table_rankings.second.play).to eq first_user_second_play
              expect(table_rankings.second.points).to eq 6
              expect(table_rankings.second.position).to eq 2

              expect(table_rankings.third.play).to eq second_user_second_play
              expect(table_rankings.third.points).to eq 6
              expect(table_rankings.third.position).to eq 2
            end
          end

          context 'when the table gives points to two users' do
            let(:points_for_winners) { [200, 100, 10] }

            context 'when there are no other rankings' do
              xit 'creates rankings for all the users giving points just to the users with highest ranking on the tournament followed by the oldest users' do
                calculator.call

                table_rankings = table.table_rankings
                expect(table_rankings).to have(3).items

                expect(table_rankings.first.play).to eq third_user_second_play
                expect(table_rankings.first.points).to eq 200
                expect(table_rankings.first.position).to eq 1

                expect(table_rankings.second.play).to eq first_user_second_play
                expect(table_rankings.second.points).to eq 100
                expect(table_rankings.second.position).to eq 2

                expect(table_rankings.third.play).to eq second_user_second_play
                expect(table_rankings.third.points).to eq 100
                expect(table_rankings.third.position).to eq 2
              end
            end

            context 'when the users have rankings for another tournament' do
              let(:another_tournament) { FactoryGirl.create(:tournament) }
              let!(:first_user_another_ranking) { FactoryGirl.create(:ranking, tournament: another_tournament, user: first_user, points: 100) }
              let!(:second_user_another_ranking) { FactoryGirl.create(:ranking, tournament: another_tournament, user: second_user, points: 100) }
              let!(:third_user_another_ranking) { FactoryGirl.create(:ranking, tournament: another_tournament, user: third_user, points: 1000) }

              xit 'does not take into account the other rankings and creates rankings for all the users giving points just to the users with highest ranking on the tournament followed by the oldest users' do
                calculator.call

                table_rankings = table.table_rankings
                expect(table_rankings).to have(3).items

                expect(table_rankings.first.play).to eq third_user_second_play
                expect(table_rankings.first.points).to eq 200
                expect(table_rankings.first.position).to eq 1

                expect(table_rankings.second.play).to eq first_user_second_play
                expect(table_rankings.second.points).to eq 100
                expect(table_rankings.second.position).to eq 2

                expect(table_rankings.third.play).to eq second_user_second_play
                expect(table_rankings.third.points).to eq 100
                expect(table_rankings.third.position).to eq 2
              end
            end

            context 'when there are more users with rankings for another tournament' do
              let(:another_tournament) { FactoryGirl.create(:tournament) }
              let!(:first_user_another_ranking) { FactoryGirl.create(:ranking, tournament: another_tournament, user: first_user, points: 100) }
              let!(:second_user_another_ranking) { FactoryGirl.create(:ranking, tournament: another_tournament, user: second_user, points: 100) }
              let!(:third_user_another_ranking) { FactoryGirl.create(:ranking, tournament: another_tournament, user: third_user, points: 1000) }
              let!(:fourth_user_another_ranking) { FactoryGirl.create(:ranking, tournament: another_tournament, user: FactoryGirl.create(:user), points: 500) }

              xit 'does not take into account the other rankings and creates rankings for all the users giving points just to the users with highest ranking on the tournament followed by the oldest users' do
                calculator.call

                table_rankings = table.table_rankings
                expect(table_rankings).to have(3).items

                expect(table_rankings.first.play).to eq third_user_second_play
                expect(table_rankings.first.points).to eq 200
                expect(table_rankings.first.position).to eq 1

                expect(table_rankings.second.play).to eq first_user_second_play
                expect(table_rankings.second.points).to eq 100
                expect(table_rankings.second.position).to eq 2

                expect(table_rankings.third.play).to eq second_user_second_play
                expect(table_rankings.third.points).to eq 100
                expect(table_rankings.third.position).to eq 2
              end
            end
          end
        end
      end
    end
  end

  context 'for a private table' do
    let(:group) { FactoryGirl.create(:group) }
    let(:table) { FactoryGirl.create(:table, tournament: tournament, points_for_winners: points_for_winners, group: group) }
    let(:first_user) { FactoryGirl.create(:user) }
    let(:second_user) { FactoryGirl.create(:user) }
    let(:third_user) { FactoryGirl.create(:user) }

    context 'when all the users have played in this table' do
      let(:points_for_winners) { [] }
      let!(:first_user_play) { FactoryGirl.create(:play, user: first_user, table: table, points: first_user_points) }
      let!(:second_user_play) { FactoryGirl.create(:play, user: second_user, table: table, points: second_user_points) }
      let!(:third_user_play) { FactoryGirl.create(:play, user: third_user, table: table, points: third_user_points) }

      context 'when all the scores are positive' do
        let(:first_user_points) { 4 }
        let(:second_user_points) { 5 }
        let(:third_user_points) { 6 }

        it 'creates rankings for all the users giving points based on the play points' do
          calculator.call

          table_rankings = table.table_rankings
          expect(table_rankings).to have(3).items

          expect(table_rankings.first.play).to eq third_user_play
          expect(table_rankings.first.points).to eq 6
          expect(table_rankings.first.position).to eq 1

          expect(table_rankings.second.play).to eq second_user_play
          expect(table_rankings.second.points).to eq 5
          expect(table_rankings.second.position).to eq 2

          expect(table_rankings.third.play).to eq first_user_play
          expect(table_rankings.third.points).to eq 4
          expect(table_rankings.third.position).to eq 3
        end
      end

      context 'when some scores are negative' do
        let(:first_user_points) { 4 }
        let(:second_user_points) { -5 }
        let(:third_user_points) { -1 }

        context 'when the table does not give points for winners' do
          let(:points_for_winners) { [] }

          it 'creates rankings for all the users giving points based on the play points' do
            calculator.call

            table_rankings = table.table_rankings
            expect(table_rankings).to have(3).items

            expect(table_rankings.first.play).to eq first_user_play
            expect(table_rankings.first.points).to eq 4
            expect(table_rankings.first.position).to eq 1

            expect(table_rankings.second.play).to eq third_user_play
            expect(table_rankings.second.points).to eq 0
            expect(table_rankings.second.position).to eq 2

            expect(table_rankings.third.play).to eq second_user_play
            expect(table_rankings.third.points).to eq 0
            expect(table_rankings.third.position).to eq 3
          end
        end

        context 'when table gives points for the first two users' do
          let(:points_for_winners) { [100, 50] }

          xit 'creates rankings for all the users giving points based for the first two winners' do
            calculator.call

            table_rankings = table.table_rankings
            expect(table_rankings).to have(3).items

            expect(table_rankings.first.play).to eq first_user_play
            expect(table_rankings.first.points).to eq 100
            expect(table_rankings.first.position).to eq 1

            expect(table_rankings.second.play).to eq third_user_play
            expect(table_rankings.second.points).to eq 50
            expect(table_rankings.second.position).to eq 2

            expect(table_rankings.third.play).to eq second_user_play
            expect(table_rankings.third.points).to eq 0
            expect(table_rankings.third.position).to eq 3
          end
        end
      end

      context 'when all the users have made same scores' do
        let(:first_user_points) { 6 }
        let(:second_user_points) { 6 }
        let(:third_user_points) { 6 }

        context 'when the table does not give points for winners' do
          let(:points_for_winners) { [] }

          it 'creates rankings for all the users without giving points based on the oldest users' do
            calculator.call

            table_rankings = table.table_rankings
            expect(table_rankings).to have(3).items

            expect(table_rankings.first.play).to eq first_user_play
            expect(table_rankings.first.points).to eq 6
            expect(table_rankings.first.position).to eq 1

            expect(table_rankings.second.play).to eq second_user_play
            expect(table_rankings.second.points).to eq 6
            expect(table_rankings.second.position).to eq 1

            expect(table_rankings.third.play).to eq third_user_play
            expect(table_rankings.third.points).to eq 6
            expect(table_rankings.third.position).to eq 1
          end
        end

        context 'when table gives points for the first two users' do
          let(:points_for_winners) { [100, 50] }

          xit 'creates rankings for all the users giving points based for the first two winners' do
            calculator.call

            table_rankings = table.table_rankings
            expect(table_rankings).to have(3).items

            expect(table_rankings.first.play).to eq first_user_play
            expect(table_rankings.first.points).to eq 100
            expect(table_rankings.first.position).to eq 1

            expect(table_rankings.second.play).to eq second_user_play
            expect(table_rankings.second.points).to eq 100
            expect(table_rankings.second.position).to eq 1

            expect(table_rankings.third.play).to eq third_user_play
            expect(table_rankings.third.points).to eq 100
            expect(table_rankings.third.position).to eq 1
          end
        end
      end
    end
  end
end
