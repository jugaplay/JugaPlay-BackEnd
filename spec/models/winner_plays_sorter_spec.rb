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

  context 'custom scenario' do
    let(:table) { FactoryGirl.create(:table, number_of_players: 3) }
    let(:player_848) { table.players[0] }
    let(:player_86) { table.players[1] }
    let(:player_411) { table.players[2] }
    let(:player_846) { table.players[3] }
    let(:player_2850) { table.players[4] }
    let(:player_21) { table.players[5] }
    let(:player_397) { table.players[6] }
    let(:player_413) { table.players[7] }
    let(:player_88) { table.players[8] }
    let(:player_812) { table.players[9] }
    let(:player_3696) { table.players[10] }
    let(:player_84) { table.players[11] }
    let(:player_84) { table.players[12] }

    let(:user_16036) { FactoryGirl.create(:user, first_name: '16036') }
    let(:user_16036_play) { FactoryGirl.create(:play, user: user_16036, table: table, points: 65.5) }
    let(:user_16035) { FactoryGirl.create(:user, first_name: '16035') }
    let(:user_16035_play) { FactoryGirl.create(:play, user: user_16035, table: table, points: 65.5) }
    let(:user_20) { FactoryGirl.create(:user, first_name: '20') }
    let(:user_20_play) { FactoryGirl.create(:play, user: user_20, table: table, points: 65.5) }
    let(:user_19) { FactoryGirl.create(:user, first_name: '19') }
    let(:user_19_play) { FactoryGirl.create(:play, user: user_19, table: table, points: 65.5) }
    let(:user_16) { FactoryGirl.create(:user, first_name: '16') }
    let(:user_16_play) { FactoryGirl.create(:play, user: user_16, table: table, points: 52.5) }
    let(:user_8) { FactoryGirl.create(:user, first_name: '8') }
    let(:user_8_play) { FactoryGirl.create(:play, user: user_8, table: table, points: 0) }
    let(:user_3) { FactoryGirl.create(:user, first_name: '3') }
    let(:user_3_play) { FactoryGirl.create(:play, user: user_3, table: table, points: 31.0) }
    let(:user_74) { FactoryGirl.create(:user, first_name: '74') }
    let(:user_74_play) { FactoryGirl.create(:play, user: user_74, table: table, points: 65.5) }
    let(:user_730) { FactoryGirl.create(:user, first_name: '730') }
    let(:user_730_play) { FactoryGirl.create(:play, user: user_730, table: table, points: 65.5) }
    let(:user_12) { FactoryGirl.create(:user, first_name: '12') }
    let(:user_12_play) { FactoryGirl.create(:play, user: user_12, table: table, points: 65.5) }

    before do
      FactoryGirl.create(:player_selection, play: user_16036_play, player: player_848, position: 1, points: 5.5)
      FactoryGirl.create(:player_selection, play: user_16036_play, player: player_86, position: 2, points: 33.0)
      FactoryGirl.create(:player_selection, play: user_16036_play, player: player_84, position: 3, points: 27.0)

      FactoryGirl.create(:player_selection, play: user_16035_play, player: player_848, position: 1, points: 5.5)
      FactoryGirl.create(:player_selection, play: user_16035_play, player: player_86, position: 2, points: 33.0)
      FactoryGirl.create(:player_selection, play: user_16035_play, player: player_84, position: 3, points: 27.0)

      FactoryGirl.create(:player_selection, play: user_20_play, player: player_848, position: 1, points: 5.5)
      FactoryGirl.create(:player_selection, play: user_20_play, player: player_86, position: 2, points: 33.0)
      FactoryGirl.create(:player_selection, play: user_20_play, player: player_84, position: 3, points: 27.0)

      FactoryGirl.create(:player_selection, play: user_19_play, player: player_848, position: 1, points: 5.5)
      FactoryGirl.create(:player_selection, play: user_19_play, player: player_86, position: 2, points: 33.0)
      FactoryGirl.create(:player_selection, play: user_19_play, player: player_84, position: 3, points: 27.0)

      FactoryGirl.create(:player_selection, play: user_16_play, player: player_411, position: 1, points: 4.5)
      FactoryGirl.create(:player_selection, play: user_16_play, player: player_846, position: 2, points: 48.0)
      FactoryGirl.create(:player_selection, play: user_16_play, player: player_2850, position: 3, points: 0.0)

      FactoryGirl.create(:player_selection, play: user_8_play, player: player_21, position: 1, points: 0.0)
      FactoryGirl.create(:player_selection, play: user_8_play, player: player_397, position: 2, points: 0.0)
      FactoryGirl.create(:player_selection, play: user_8_play, player: player_413, position: 3, points: 0.0)

      FactoryGirl.create(:player_selection, play: user_3_play, player: player_88, position: 1, points: 31.0)
      FactoryGirl.create(:player_selection, play: user_3_play, player: player_812, position: 2, points: 0.0)
      FactoryGirl.create(:player_selection, play: user_3_play, player: player_3696, position: 3, points: 0.0)

      FactoryGirl.create(:player_selection, play: user_74_play, player: player_84, position: 1, points: 27.0)
      FactoryGirl.create(:player_selection, play: user_74_play, player: player_86, position: 2, points: 33.0)
      FactoryGirl.create(:player_selection, play: user_74_play, player: player_848, position: 3, points: 5.5)

      FactoryGirl.create(:player_selection, play: user_730_play, player: player_84, position: 1, points: 27.0)
      FactoryGirl.create(:player_selection, play: user_730_play, player: player_86, position: 2, points: 33.0)
      FactoryGirl.create(:player_selection, play: user_730_play, player: player_848, position: 3, points: 5.5)

      FactoryGirl.create(:player_selection, play: user_12_play, player: player_86, position: 1, points: 33.0)
      FactoryGirl.create(:player_selection, play: user_12_play, player: player_84, position: 2, points: 27.0)
      FactoryGirl.create(:player_selection, play: user_12_play, player: player_848, position: 3, points: 5.5)
    end

    it 'returns the plays well sorted' do
      plays = finder.call

      expect(plays).to have(6).items
      expect(plays[0]).to have(1).item
      expect(plays[0]).to include user_12_play
      expect(plays[1]).to have(2).items
      expect(plays[1]).to include user_730_play, user_74_play
      expect(plays[2]).to have(4).items
      expect(plays[2]).to include user_16036_play, user_16035_play, user_19_play, user_20_play
      expect(plays[3]).to have(1).item
      expect(plays[3]).to include user_16_play
      expect(plays[4]).to have(1).item
      expect(plays[4]).to include user_3_play
      expect(plays[5]).to have(1).item
      expect(plays[5]).to include user_8_play
    end
  end

  context 'custom scenario 2' do
    let(:table) { FactoryGirl.create(:table, number_of_players: 3) }
    let(:player_1_1) { table.players[0] }
    let(:player_1_2) { table.players[1] }
    let(:player_1_3) { table.players[2] }
    let(:player_2_1) { table.players[3] }
    let(:player_2_2) { table.players[4] }
    let(:player_2_3) { table.players[5] }
    let(:player_3_1) { table.players[6] }
    let(:player_3_2) { table.players[7] }
    let(:player_3_3) { table.players[8] }

    let(:user_1) { FactoryGirl.create(:user, first_name: '61555') }
    let(:user_1_play) { FactoryGirl.create(:play, user: user_1, table: table, points: 37.0) }
    let(:user_2) { FactoryGirl.create(:user, first_name: '61166') }
    let(:user_2_play) { FactoryGirl.create(:play, user: user_2, table: table, points: 37.0) }
    let(:user_3) { FactoryGirl.create(:user, first_name: '61429') }
    let(:user_3_play) { FactoryGirl.create(:play, user: user_3, table: table, points: 37.0) }

    before do
      FactoryGirl.create(:player_selection, play: user_1_play, player: player_1_1, position: 1, points: 12.5)
      FactoryGirl.create(:player_selection, play: user_1_play, player: player_1_2, position: 2, points: 19.5)
      FactoryGirl.create(:player_selection, play: user_1_play, player: player_1_3, position: 3, points: 5.0)

      FactoryGirl.create(:player_selection, play: user_2_play, player: player_2_1, position: 1, points: 12.5)
      FactoryGirl.create(:player_selection, play: user_2_play, player: player_2_2, position: 2, points: 5.0)
      FactoryGirl.create(:player_selection, play: user_2_play, player: player_2_3, position: 3, points: 19.5)

      FactoryGirl.create(:player_selection, play: user_3_play, player: player_3_1, position: 1, points: 10.5)
      FactoryGirl.create(:player_selection, play: user_3_play, player: player_3_2, position: 2, points: 19.5)
      FactoryGirl.create(:player_selection, play: user_3_play, player: player_3_3, position: 3, points: 7.0)
    end

    it 'returns the plays well sorted' do
      plays = finder.call

      expect(plays).to have(3).items
      expect(plays[0]).to have(1).item
      expect(plays[0]).to include user_1_play
      expect(plays[1]).to have(1).item
      expect(plays[1]).to include user_2_play
      expect(plays[2]).to have(1).item
      expect(plays[2]).to include user_3_play
    end
  end
end
