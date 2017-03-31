require 'spec_helper'

describe WinnerPlaysSorter do
  let(:tournament) { FactoryGirl.create(:tournament) }
  let(:finder) { WinnerPlaysSorter.new(table) }

  context 'for a public table' do
    let!(:table) { FactoryGirl.create(:table, tournament: tournament) }
    let!(:another_table) { FactoryGirl.create(:table, tournament: tournament) }

    context 'when there are 3 users' do
      let!(:first_user) { FactoryGirl.create(:user) }
      let!(:second_user) { FactoryGirl.create(:user) }
      let!(:third_user) { FactoryGirl.create(:user) }

      context 'when all the users have played in this table' do
        let!(:first_user_play) { FactoryGirl.create(:play, user: first_user, table: table, points: first_user_points) }
        let!(:second_user_play) { FactoryGirl.create(:play, user: second_user, table: table, points: second_user_points) }
        let!(:third_user_play) { FactoryGirl.create(:play, user: third_user, table: table, points: third_user_points) }

        context 'when all the scores are positive' do
          let(:first_user_points) { 4 }
          let(:second_user_points) { 5 }
          let(:third_user_points) { 6 }

          it 'returns the plays order by points' do
            plays = finder.call

            expect(plays).to have(3).items
            expect(plays.first).to have(1).item
            expect(plays.first).to include third_user_play
            expect(plays.second).to have(1).item
            expect(plays.second).to include second_user_play
            expect(plays.third).to have(1).item
            expect(plays.third).to include first_user_play
          end
        end

        context 'when some scores are negative' do
          let(:first_user_points) { 4 }
          let(:second_user_points) { -5 }
          let(:third_user_points) { -1 }

          it 'returns the plays order by points' do
            plays = finder.call

            expect(plays).to have(3).items
            expect(plays.first).to have(1).item
            expect(plays.first).to include first_user_play
            expect(plays.second).to have(1).item
            expect(plays.second).to include third_user_play
            expect(plays.third).to have(1).item
            expect(plays.third).to include second_user_play
          end
        end

        context 'when all the users have made same scores' do
          let(:first_user_points) { 6 }
          let(:second_user_points) { 6 }
          let(:third_user_points) { 6 }

          context 'when the first and the third users selected 2 players, but the second user selected 1 player' do
            let(:first_user_first_player) { table.matches.first.local_team.players[0] }
            let(:first_user_second_player) { table.matches.first.local_team.players[1] }
            let(:second_user_player) { table.matches.first.local_team.players[2] }
            let(:third_user_first_player) { table.matches.first.visitor_team.players[1] }
            let(:third_user_second_player) { table.matches.first.visitor_team.players[0] }

            before do
              first_user_play.update_attributes!(player_selections: [])
              second_user_play.update_attributes!(player_selections: [])
              third_user_play.update_attributes!(player_selections: [])

              FactoryGirl.create(:player_selection, play: first_user_play, player: first_user_first_player, position: 1, points: first_user_first_player_points)
              FactoryGirl.create(:player_selection, play: first_user_play, player: first_user_second_player, position: 2, points: first_user_second_player_points)
              FactoryGirl.create(:player_selection, play: second_user_play, player: second_user_player, position: 1, points: second_user_player_points)
              FactoryGirl.create(:player_selection, play: third_user_play, player: third_user_first_player, position: 1, points: third_user_first_player_points)
              FactoryGirl.create(:player_selection, play: third_user_play, player: third_user_second_player, position: 2, points: third_user_second_player_points)
            end

            context 'when the players selected for the plays scored different points' do
              let(:first_user_first_player_points) { 4 }
              let(:first_user_second_player_points) { 2 }
              let(:third_user_first_player_points) { 2 }
              let(:third_user_second_player_points) { 4 }
              let(:second_user_player_points) { 6 }

              it 'returns the plays order by the first player that scored more points' do
                plays = finder.call

                expect(plays).to have(3).items
                expect(plays.first).to have(1).item
                expect(plays.first).to include second_user_play
                expect(plays.second).to have(1).item
                expect(plays.second).to include first_user_play
                expect(plays.third).to have(1).item
                expect(plays.third).to include third_user_play
              end
            end

            context 'when the some players selected for the plays scored same points' do
              let(:first_user_first_player_points) { 4 }
              let(:first_user_second_player_points) { 2 }
              let(:third_user_first_player_points) { 4 }
              let(:third_user_second_player_points) { 2 }
              let(:second_user_player_points) { 6 }

              it 'returns the plays order by the first player that scored more points, joining the players that scored the same points' do
                plays = finder.call

                expect(plays).to have(2).items
                expect(plays.first).to have(1).item
                expect(plays.first).to include second_user_play
                expect(plays.second).to have(2).items
                expect(plays.second).to include first_user_play, third_user_play
              end
            end

            context 'when the some players selected for the plays scored same points' do
              let(:first_user_first_player_points) { 4 }
              let(:first_user_second_player_points) { 2 }
              let(:third_user_first_player_points) { 4 }
              let(:third_user_second_player_points) { 3 }
              let(:second_user_player_points) { 6 }

              it 'returns the plays order by the first player that scored more points, joining the players that scored the same points' do
                plays = finder.call

                expect(plays).to have(3).items
                expect(plays.first).to have(1).item
                expect(plays.first).to include second_user_play
                expect(plays.second).to have(1).item
                expect(plays.second).to include third_user_play
                expect(plays.third).to have(1).item
                expect(plays.third).to include first_user_play
              end
            end
          end
        end
      end
    end
  end

  context 'for a private table' do
    let(:group) { FactoryGirl.create(:group) }
    let(:table) { FactoryGirl.create(:table, tournament: tournament, group: group) }
    let(:first_user) { FactoryGirl.create(:user) }
    let(:second_user) { FactoryGirl.create(:user) }
    let(:third_user) { FactoryGirl.create(:user) }

    context 'when all the users have played in this table' do
      let!(:first_user_play) { FactoryGirl.create(:play, user: first_user, table: table, points: first_user_points) }
      let!(:second_user_play) { FactoryGirl.create(:play, user: second_user, table: table, points: second_user_points) }
      let!(:third_user_play) { FactoryGirl.create(:play, user: third_user, table: table, points: third_user_points) }

      context 'when all the scores are positive' do
        let(:first_user_points) { 4 }
        let(:second_user_points) { 5 }
        let(:third_user_points) { 6 }


        it 'returns the third, the second and the first user plays' do
          plays = finder.call

          expect(plays).to have(3).items
          expect(plays.first).to have(1).item
          expect(plays.first).to include third_user_play
          expect(plays.second).to have(1).item
          expect(plays.second).to include second_user_play
          expect(plays.third).to have(1).item
          expect(plays.third).to include first_user_play
        end
      end

      context 'when some scores are negative' do
        let(:first_user_points) { 4 }
        let(:second_user_points) { -5 }
        let(:third_user_points) { -1 }

        it 'returns the first, the third and the second user plays' do
          plays = finder.call

          expect(plays).to have(3).items
          expect(plays.first).to have(1).item
          expect(plays.first).to include first_user_play
          expect(plays.second).to have(1).item
          expect(plays.second).to include third_user_play
          expect(plays.third).to have(1).item
          expect(plays.third).to include second_user_play
        end
      end

      context 'when all the users have made same scores' do
        let(:first_user_points) { 6 }
        let(:second_user_points) { 6 }
        let(:third_user_points) { 6 }

        context 'when all the users selected 2 players' do
          let(:first_user_first_player) { table.matches.first.local_team.players[0] }
          let(:first_user_second_player) { table.matches.first.local_team.players[1] }
          let(:second_user_first_player) { table.matches.first.local_team.players[2] }
          let(:second_user_second_player) { table.matches.first.visitor_team.players[2] }
          let(:third_user_first_player) { table.matches.first.visitor_team.players[1] }
          let(:third_user_second_player) { table.matches.first.visitor_team.players[0] }

          before do
            first_user_play.update_attributes!(player_selections: [])
            second_user_play.update_attributes!(player_selections: [])
            third_user_play.update_attributes!(player_selections: [])

            FactoryGirl.create(:player_selection, play: first_user_play, player: first_user_first_player, position: 1, points: first_user_first_player_points)
            FactoryGirl.create(:player_selection, play: first_user_play, player: first_user_second_player, position: 2, points: first_user_second_player_points)
            FactoryGirl.create(:player_selection, play: second_user_play, player: second_user_first_player, position: 1, points: second_user_first_player_points)
            FactoryGirl.create(:player_selection, play: second_user_play, player: second_user_second_player, position: 2, points: second_user_second_player_points)
            FactoryGirl.create(:player_selection, play: third_user_play, player: third_user_first_player, position: 1, points: third_user_first_player_points)
            FactoryGirl.create(:player_selection, play: third_user_play, player: third_user_second_player, position: 2, points: third_user_second_player_points)
          end

          context 'when the players selected for the plays scored different points' do
            let(:first_user_first_player_points) { 4 }
            let(:first_user_second_player_points) { 2 }
            let(:second_user_first_player_points) { 6 }
            let(:second_user_second_player_points) { 0 }
            let(:third_user_first_player_points) { 2 }
            let(:third_user_second_player_points) { 4 }

            it 'returns the plays order by the first player that scored more points' do
              plays = finder.call

              expect(plays).to have(3).items
              expect(plays.first).to have(1).item
              expect(plays.first).to include second_user_play
              expect(plays.second).to have(1).item
              expect(plays.second).to include first_user_play
              expect(plays.third).to have(1).item
              expect(plays.third).to include third_user_play
            end
          end

          context 'when the some players selected for the plays scored same points' do
            let(:first_user_first_player_points) { 4 }
            let(:first_user_second_player_points) { 2 }
            let(:second_user_first_player_points) { 6 }
            let(:second_user_second_player_points) { 0 }
            let(:third_user_first_player_points) { 4 }
            let(:third_user_second_player_points) { 2 }

            it 'returns the plays order by the first player that scored more points, joining the players that scored the same points' do
              plays = finder.call

              expect(plays).to have(2).items
              expect(plays.first).to have(1).item
              expect(plays.first).to include second_user_play
              expect(plays.second).to have(2).items
              expect(plays.second).to include first_user_play, third_user_play
            end
          end

          context 'when the some players selected for the plays scored same points' do
            let(:first_user_first_player_points) { 4 }
            let(:first_user_second_player_points) { 2 }
            let(:second_user_first_player_points) { 6 }
            let(:second_user_second_player_points) { 0 }
            let(:third_user_first_player_points) { 4 }
            let(:third_user_second_player_points) { 3 }

            it 'returns the plays order by the first player that scored more points, joining the players that scored the same points' do
              plays = finder.call

              expect(plays).to have(3).items
              expect(plays.first).to have(1).item
              expect(plays.first).to include second_user_play
              expect(plays.second).to have(1).item
              expect(plays.second).to include third_user_play
              expect(plays.third).to have(1).item
              expect(plays.third).to include first_user_play
            end
          end

          context 'when the all players selected for the plays scored same points' do
            let(:first_user_first_player_points) { 3 }
            let(:first_user_second_player_points) { 3 }
            let(:third_user_first_player_points) { 3 }
            let(:third_user_second_player_points) { 3 }
            let(:second_user_first_player_points) { 3 }
            let(:second_user_second_player_points) { 3 }

            it 'returns the plays order by the first player that scored more points, joining the players that scored the same points' do
              plays = finder.call

              expect(plays).to have(1).item
              expect(plays.first).to have(3).item
              expect(plays.first).to include second_user_play, third_user_play, first_user_play
            end
          end
        end
      end
    end
  end
end
