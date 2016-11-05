require 'spec_helper'

describe RankingPointsUpdater do
  context 'when no tournament is given' do
    let(:ranking_updater) { RankingPointsUpdater.new(users: ['user'], points_for_winners: [1]) }

    it 'raise an error' do
      expect { ranking_updater }.to raise_error ArgumentError
    end
  end

  context 'when no users are given' do
    let(:ranking_updater) { RankingPointsUpdater.new(tournament: 'tournament', points_for_winners: [1]) }

    it 'raise an error' do
      expect { ranking_updater }.to raise_error ArgumentError
    end
  end

  context 'when no points for winners are given' do
    let(:ranking_updater) { RankingPointsUpdater.new(tournament: 'tournament', users: ['user']) }

    it 'raise an error' do
      expect { ranking_updater }.to raise_error ArgumentError
    end
  end

  context 'when a tournament, users and points for winners are given' do
    let(:ranking_updater) { RankingPointsUpdater.new(tournament: tournament, users: users, points_for_winners: points_for_winners) }
    let(:tournament) { FactoryGirl.create(:tournament) }
    let(:ranking) { tournament.rankings }

    context 'when there are two users playing' do
      let(:users) { [first_user, second_user] }
      let(:first_user) { FactoryGirl.create(:user) }
      let(:second_user) { FactoryGirl.create(:user) }

      context 'when there are points for one user' do
        let(:points_for_winners) { [100] }

        context 'when the users have no rankings' do
          context 'when the last position in the ranking is 130' do
            let!(:another_user_ranking) { FactoryGirl.create(:ranking, tournament: tournament, position: 130) }

            it 'creates a ranking for the users at the bottom of the list and assigns points to the first given user' do
              ranking_updater.call

              expect(ranking).to have(3).items
              expect(ranking.first.user).to eq another_user_ranking.user
              expect(ranking.second.user).to eq first_user
              expect(ranking.second.position).to eq 131
              expect(ranking.second.points).to eq 100.0
              expect(ranking.third.user).to eq second_user
              expect(ranking.third.position).to eq 132
              expect(ranking.third.points).to eq 0.0
            end
          end

          context 'when there is no user in the ranking' do
            it 'creates a ranking for the users using the first positions and assigns points to the first user' do
              ranking_updater.call

              expect(ranking).to have(2).items
              expect(ranking.first.user).to eq first_user
              expect(ranking.first.position).to eq 1
              expect(ranking.first.points).to eq 100.0
              expect(ranking.second.user).to eq second_user
              expect(ranking.second.position).to eq 2
              expect(ranking.second.points).to eq 0.0
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

      context 'when there are points for two users' do
        let(:points_for_winners) { [100, 10] }

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

      context 'when there points for three users' do
        let(:points_for_winners) { [100, 10, 1] }

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
end
