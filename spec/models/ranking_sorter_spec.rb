require 'spec_helper'

describe RankingSorter do
  let(:ranking_sorter) { RankingSorter.new(tournament) }

  context 'when no tournament is given' do
    let(:tournament) { nil }

    it 'raise an error' do
      expect { ranking_sorter }.to raise_error ArgumentError
    end
  end
  
  context 'when a tournament is given' do
    let(:tournament) { FactoryGirl.create(:tournament) }
    let(:first_user) { FactoryGirl.create(:user) }
    let(:second_user) { FactoryGirl.create(:user) }
    let!(:first_user_ranking) { FactoryGirl.create(:ranking, tournament: tournament, points: first_user_points, position: 1, user: first_user) }
    let!(:second_user_ranking) { FactoryGirl.create(:ranking, tournament: tournament, points: second_user_points, position: 2, user: second_user) }

    context 'when all the users have different points' do
      let(:first_user_points) { 10 }
      let(:second_user_points) { 100 }

      it 'sorts their rankings by the amount of points' do
        expect(first_user.ranking_on_tournament(tournament).position).to eq 1
        expect(second_user.ranking_on_tournament(tournament).position).to eq 2

        ranking_sorter.call

        expect(second_user.ranking_on_tournament(tournament).position).to eq 1
        expect(first_user.ranking_on_tournament(tournament).position).to eq 2
      end
    end

    context 'when some users have the same points' do
      let(:third_user) { FactoryGirl.create(:user) }
      let!(:third_user_ranking) { FactoryGirl.create(:ranking, tournament: tournament, points: third_user_points, position: 3, user: third_user) }
      let(:first_user_points) { 10 }
      let(:second_user_points) { 100 }
      let(:third_user_points) { 10 }

      it 'sorts their rankings by the date of creation of the user' do
        expect(first_user.ranking_on_tournament(tournament).position).to eq 1
        expect(second_user.ranking_on_tournament(tournament).position).to eq 2
        expect(third_user.ranking_on_tournament(tournament).position).to eq 3

        ranking_sorter.call

        expect(second_user.ranking_on_tournament(tournament).position).to eq 1
        expect(first_user.ranking_on_tournament(tournament).position).to eq 2
        expect(third_user.ranking_on_tournament(tournament).position).to eq 3
      end
    end
  end
end
