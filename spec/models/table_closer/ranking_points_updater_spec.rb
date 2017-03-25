require 'spec_helper'

describe RankingPointsUpdater do
  let(:ranking_updater) { RankingPointsUpdater.new(table) }

  let(:table) { FactoryGirl.create(:table) }
  let(:tournament) { table.tournament }
  let(:ranking) { tournament.rankings }

  context 'when there are two users playing' do
    let(:first_user) { FactoryGirl.create(:user) }
    let(:second_user) { FactoryGirl.create(:user) }

    context 'when just the first user has played in that table and won some points' do
      let(:play) { FactoryGirl.create(:play, user: first_user, table: table, points: 10) }
      let!(:first_user_table_ranking) { FactoryGirl.create(:table_ranking, play: play, position: 1, points: 100) }

      context 'when the users have no rankings' do
        context 'when the last position in the ranking is 130' do
          let!(:another_user_ranking) { FactoryGirl.create(:ranking, tournament: tournament, position: 130) }

          it 'creates a ranking for the first user at the bottom of the list and assigns the table ranking points' do
            ranking_updater.call

            expect(ranking).to have(2).items
            expect(ranking.first.user).to eq another_user_ranking.user
            expect(ranking.second.user).to eq first_user
            expect(ranking.second.position).to eq 131
            expect(ranking.second.points).to eq 100.0
          end
        end

        context 'when there is no user in the ranking' do
          it 'creates a ranking for the first user at the first position and assigns the table ranking points' do
            ranking_updater.call

            expect(ranking).to have(1).items
            expect(ranking.first.user).to eq first_user
            expect(ranking.first.position).to eq 1
            expect(ranking.first.points).to eq 100.0
          end
        end
      end

      context 'when the users have rankings' do
        let!(:first_user_ranking) { FactoryGirl.create(:ranking, tournament: tournament, user: first_user, points: 1, position: 5) }
        let!(:second_user_ranking) { FactoryGirl.create(:ranking, tournament: tournament, user: second_user, points: 98, position: 7) }

        it 'updates the points of the first user' do
          ranking_updater.call

          expect(ranking).to have(2).items
          expect(ranking.first.user).to eq first_user
          expect(ranking.first.position).to eq 5
          expect(ranking.first.points).to eq 101.0
          expect(ranking.second.user).to eq second_user
          expect(ranking.second.position).to eq 7
          expect(ranking.second.points).to eq 98.0
        end
      end
    end

    context 'when both users have played in that table and won some points' do
      let(:play) { FactoryGirl.create(:play, user: first_user, table: table, points: 10) }
      let!(:first_user_table_ranking) { FactoryGirl.create(:table_ranking, play: play, position: 1, points: 100) }

      let(:another_play) { FactoryGirl.create(:play, user: second_user, table: table, points: 8) }
      let!(:second_user_table_ranking) { FactoryGirl.create(:table_ranking, play: another_play, position: 2, points: 10) }

      context 'when the users have no rankings' do
        context 'when the last position in the ranking is 130' do
          let!(:another_user_ranking) { FactoryGirl.create(:ranking, tournament: tournament, position: 130) }

          it 'creates a ranking for the users at the bottom of the list and assigns points to both users' do
            ranking_updater.call

            expect(ranking).to have(3).items
            expect(ranking.first.user).to eq another_user_ranking.user
            expect(ranking.second.user).to eq first_user
            expect(ranking.second.position).to eq 131
            expect(ranking.second.points).to eq 100.0
            expect(ranking.third.user).to eq second_user
            expect(ranking.third.position).to eq 132
            expect(ranking.third.points).to eq 10.0
          end
        end

        context 'when there is no user in the ranking' do
          it 'creates a ranking for the users using the first positions and assigns points to both users' do
            ranking_updater.call

            expect(ranking).to have(2).items
            expect(ranking.first.user).to eq first_user
            expect(ranking.first.position).to eq 1
            expect(ranking.first.points).to eq 100.0
            expect(ranking.second.user).to eq second_user
            expect(ranking.second.position).to eq 2
            expect(ranking.second.points).to eq 10.0
          end
        end
      end

      context 'when the users have rankings' do
        let!(:first_user_ranking) { FactoryGirl.create(:ranking, tournament: tournament, user: first_user, points: 1, position: 5) }
        let!(:second_user_ranking) { FactoryGirl.create(:ranking, tournament: tournament, user: second_user, points: 98, position: 7) }

        it 'updates the points of both users' do
          ranking_updater.call

          expect(ranking).to have(2).items
          expect(ranking.first.user).to eq first_user
          expect(ranking.first.position).to eq 5
          expect(ranking.first.points).to eq 101.0
          expect(ranking.second.user).to eq second_user
          expect(ranking.second.position).to eq 7
          expect(ranking.second.points).to eq 108.0
        end
      end
    end
  end
end
