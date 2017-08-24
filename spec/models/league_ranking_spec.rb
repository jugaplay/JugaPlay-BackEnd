require 'spec_helper'

describe LeagueRanking do
  describe 'validations' do
    it 'must belong to a user' do
      user = FactoryGirl.create(:user)
      expect { FactoryGirl.create(:league_ranking, user: user) }.not_to raise_error

      expect { FactoryGirl.create(:league_ranking).update_attributes!(user: nil) }.to raise_error ActiveRecord::RecordInvalid, /User can't be blank/
    end

    it 'must belong to a league unique by user and round' do
      user = FactoryGirl.create(:user)
      league = FactoryGirl.create(:league)
      expect { FactoryGirl.create(:league_ranking, user: user, league: league, round: 1) }.not_to raise_error
      expect { FactoryGirl.create(:league_ranking, user: user, league: league, round: 2) }.not_to raise_error

      expect { FactoryGirl.create(:league_ranking, league: nil) }.to raise_error ActiveRecord::RecordInvalid, /League can't be blank/
      expect { FactoryGirl.create(:league_ranking, user: user, league: league, round: 1) }.to raise_error ActiveRecord::RecordInvalid, /League has already been taken/
    end

    it 'must have a position greater than 0' do
      expect { FactoryGirl.create(:league_ranking, position: 1) }.not_to raise_error

      expect { FactoryGirl.create(:league_ranking, position: nil) }.to raise_error ActiveRecord::RecordInvalid, /Position can't be blank/
      expect { FactoryGirl.create(:league_ranking, position: 0) }.to raise_error ActiveRecord::RecordInvalid, /Position must be greater than or equal to 1/
    end

    it 'must have an integer round greater than 0' do
      expect { FactoryGirl.create(:league_ranking, round: 1) }.not_to raise_error

      expect { FactoryGirl.create(:league_ranking, round: nil) }.to raise_error ActiveRecord::RecordInvalid, /Round can't be blank/
      expect { FactoryGirl.create(:league_ranking, round: 1.5) }.to raise_error ActiveRecord::RecordInvalid, /Round must be an integer/
      expect { FactoryGirl.create(:league_ranking, round: 0) }.to raise_error ActiveRecord::RecordInvalid, /Round must be greater than 0/
    end

    it 'must have some round points greater than or equal to 0' do
      expect { FactoryGirl.create(:league_ranking, round_points: 0) }.not_to raise_error

      expect { FactoryGirl.create(:league_ranking, round_points: nil) }.to raise_error ActiveRecord::RecordInvalid, /Round points can't be blank/
      expect { FactoryGirl.create(:league_ranking, round_points: -1) }.to raise_error ActiveRecord::RecordInvalid, /Round points must be greater than or equal to 0/
    end

    it 'must have some total points greater than or equal to 0' do
      expect { FactoryGirl.create(:league_ranking, total_points: 0) }.not_to raise_error

      expect { FactoryGirl.create(:league_ranking, total_points: nil) }.to raise_error ActiveRecord::RecordInvalid, /Total points can't be blank/
      expect { FactoryGirl.create(:league_ranking, total_points: -1) }.to raise_error ActiveRecord::RecordInvalid, /Total points must be greater than or equal to 0/
    end
  end

  describe '#old_league_ranking_rounds' do
    let(:user) { FactoryGirl.create(:user) }
    let(:league) { FactoryGirl.create(:league) }
    let!(:league_ranking_round_1) { FactoryGirl.create(:league_ranking, league: league, user: user, round: 1) }
    let!(:league_ranking_round_2) { FactoryGirl.create(:league_ranking, league: league, user: user, round: 2) }
    let!(:league_ranking_round_3) { FactoryGirl.create(:league_ranking, league: league, user: user, round: 3) }

    it 'returns the league rankings with a previous round' do
      rankings = league_ranking_round_3.all_rankings

      expect(rankings).to have(3).items
      expect(rankings.first).to eq league_ranking_round_3
      expect(rankings.second).to eq league_ranking_round_2
      expect(rankings.third).to eq league_ranking_round_1
    end
  end

  describe '#status' do
    let(:league_ranking) { FactoryGirl.create(:league_ranking, status: status) }

    context 'when a league ranking is being played' do
      let(:status) { :playing }

      it 'is being played and not ended' do
        expect(league_ranking).to be_playing
        expect(league_ranking).not_to be_ended
      end
    end

    context 'when a league ranking is ended' do
      let(:status) { :ended }

      it 'is opened, and not closed neither being playing' do
        expect(league_ranking).to be_ended
        expect(league_ranking).not_to be_playing
      end
    end
  end
end
