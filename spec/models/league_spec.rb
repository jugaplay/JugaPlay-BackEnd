require 'spec_helper'

describe League do
  describe 'validations' do
    it 'must have a title' do
      expect { FactoryGirl.create(:league, title: 'Supreclasicos') }.not_to raise_error

      expect { FactoryGirl.create(:league, title: nil) }.to raise_error ActiveRecord::RecordInvalid, /Title can't be blank/
    end

    it 'must have a description' do
      expect { FactoryGirl.create(:league, description: 'una descripción') }.not_to raise_error

      expect { FactoryGirl.create(:league, description: nil) }.to raise_error ActiveRecord::RecordInvalid, /Description can't be blank/
    end

    it 'must have a start time' do
      expect { FactoryGirl.create(:league, starts_at: Time.now) }.not_to raise_error

      expect { FactoryGirl.create(:league, starts_at: nil) }.to raise_error ActiveRecord::RecordInvalid, /Starts at can't be blank/
    end

    it 'must have some prizes greater than 0 with same currency' do
      expect { FactoryGirl.create(:league, prizes: [1.5.chips]) }.not_to raise_error
      expect { FactoryGirl.create(:league, prizes: [100.coins, 50.coins, 20.coins]) }.not_to raise_error

      expect { FactoryGirl.create(:league, prizes: []) }.to raise_error ActiveRecord::RecordInvalid, /is too short/
      expect { FactoryGirl.create(:league, prizes: [0.coins]) }.to raise_error ActiveRecord::RecordInvalid, /has a value that must be greater than 0/
      expect { FactoryGirl.create(:league, prizes: [-1]) }.to raise_error ActiveRecord::RecordInvalid, /All prizes must be money with same currency/
      expect { FactoryGirl.create(:league, prizes: [100, nil]) }.to raise_error ActiveRecord::RecordInvalid, /All prizes must be money with same currency/
    end

    it 'must have an integer frequency in days greater than 0' do
      expect { FactoryGirl.create(:league, frequency_in_days: 5) }.not_to raise_error

      expect { FactoryGirl.create(:league, frequency_in_days: 1.5) }.to raise_error ActiveRecord::RecordInvalid, /Frequency in days must be an integer/
      expect { FactoryGirl.create(:league, frequency_in_days: 0) }.to raise_error ActiveRecord::RecordInvalid, /Frequency in days must be greater than 0/
      expect { FactoryGirl.create(:league, frequency_in_days: nil) }.to raise_error ActiveRecord::RecordInvalid, /Frequency in days can't be blank/
      expect { FactoryGirl.create(:league, frequency_in_days: '') }.to raise_error ActiveRecord::RecordInvalid, /Frequency in days can't be blank/
    end
    
    it 'must have an integer period grater than 0' do
      expect { FactoryGirl.create(:league, periods: 5) }.not_to raise_error

      expect { FactoryGirl.create(:league, periods: 1.5) }.to raise_error ActiveRecord::RecordInvalid, /Periods must be an integer/
      expect { FactoryGirl.create(:league, periods: 0) }.to raise_error ActiveRecord::RecordInvalid, /Periods must be greater than 0/
      expect { FactoryGirl.create(:league, periods: nil) }.to raise_error ActiveRecord::RecordInvalid, /Periods can't be blank/
      expect { FactoryGirl.create(:league, periods: '') }.to raise_error ActiveRecord::RecordInvalid, /Periods can't be blank/
    end
  end

  describe '#ranking_for_user' do
    let(:league) { FactoryGirl.create(:league) }
    let!(:league_ranking_round_1) { FactoryGirl.create(:league_ranking, league: league, user: user, round: 1) }
    let!(:league_ranking_round_2) { FactoryGirl.create(:league_ranking, league: league, user: user, round: 2) }
    let!(:another_league_ranking_1) { FactoryGirl.create(:league_ranking, league: league, user: another_user, round: 1) }
    let!(:another_league_ranking_2) { FactoryGirl.create(:league_ranking, league: league, user: another_user, round: 2) }

    let(:user) { FactoryGirl.create(:user) }
    let(:another_user) { FactoryGirl.create(:user) }

    it 'returns the last round ranking of the given user' do
      expect(league.ranking_for_user user).to eq league_ranking_round_2
    end
  end

  describe '#status' do
    let(:league) { FactoryGirl.create(:league, status: status) }

    context 'when a league is closed' do
      let(:status) { :closed }

      it 'is closed, and not opened neither being playing' do
        expect(league).to be_closed
        expect(league).not_to be_opened
        expect(league).not_to be_playing
      end
    end

    context 'when a league is opened' do
      let(:status) { :opened }

      it 'is opened, and not closed neither being playing' do
        expect(league).to be_opened
        expect(league).not_to be_closed
        expect(league).not_to be_playing
      end
    end

    context 'when a league is being played' do
      let(:status) { :playing }

      it 'is being played, and not opened neither closed' do
        expect(league).to be_playing
        expect(league).not_to be_opened
        expect(league).not_to be_closed
      end
    end
  end
end
