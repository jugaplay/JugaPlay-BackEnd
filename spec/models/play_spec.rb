require 'spec_helper'

describe Play do
  describe 'validations' do
    it 'must have a user' do
      expect { FactoryGirl.create(:play, user: FactoryGirl.create(:user)) }.not_to raise_error

      expect { FactoryGirl.create(:play, user: nil) }.to raise_error ActiveRecord::RecordInvalid, /User can't be blank/
    end

    it 'must have a table' do
      expect { FactoryGirl.create(:play, table: FactoryGirl.create(:table)) }.not_to raise_error

      expect { FactoryGirl.create(:play, table: nil) }.to raise_error ActiveRecord::RecordInvalid, /Table can't be blank/
    end

    it 'must can have multiple unique player selections' do
      play = FactoryGirl.create(:play, player_selections: [])

      expect { FactoryGirl.create(:player_selection, play: play, position: 1, points: 0) }.not_to raise_error
      expect { FactoryGirl.create(:player_selection, play: play, position: 1, points: 0) }.to raise_error ActiveRecord::RecordInvalid, /Position has already been taken/
    end

    it 'can be only one play per user on the same table' do
      user = FactoryGirl.create(:user)
      table = FactoryGirl.create(:table)
      FactoryGirl.create(:play, user: user, table: table)

      expect { FactoryGirl.create(:play, user: user, table: table) }.to raise_error ActiveRecord::RecordInvalid, /User has already been taken/
    end

    it 'can have no points' do
      expect { FactoryGirl.create(:play, points: nil) }.not_to raise_error
      expect { FactoryGirl.create(:play, points: -1) }.not_to raise_error
      expect { FactoryGirl.create(:play, points: 0) }.not_to raise_error
      expect { FactoryGirl.create(:play, points: 5) }.not_to raise_error
      expect { FactoryGirl.create(:play, points: 5.5) }.not_to raise_error
    end

    it 'can have cost value equal or greater than zero' do
      expect { FactoryGirl.create(:play, cost_value: 0) }.not_to raise_error
      expect { FactoryGirl.create(:play, cost_value: 5) }.not_to raise_error
      expect { FactoryGirl.create(:play, cost_value: 5.5) }.not_to raise_error

      expect { FactoryGirl.create(:play, cost_value: nil) }.to raise_error ActiveRecord::RecordInvalid, /Cost value is not a number/
      expect { FactoryGirl.create(:play, cost_value: -1) }.to raise_error ActiveRecord::RecordInvalid, /Cost value must be greater than or equal to 0/
    end

    it 'must have a valid cost type' do
      expect { FactoryGirl.create(:play, cost_type: Money::CHIPS) }.not_to raise_error
      expect { FactoryGirl.create(:play, cost_type: Money::COINS) }.not_to raise_error

      expect { FactoryGirl.create(:play, cost_type: nil) }.to raise_error ActiveRecord::RecordInvalid, /Cost type can't be blank/
      expect { FactoryGirl.create(:play, cost_type: 'unkown') }.to raise_error ActiveRecord::RecordInvalid, /Cost type is not included in the list/
    end

    it 'can have no bet multiply coins or equal or greater than 2' do
      expect { FactoryGirl.create(:play, multiplier: 5) }.not_to raise_error
      expect { FactoryGirl.create(:play, multiplier: nil) }.not_to raise_error

      expect { FactoryGirl.create(:play, multiplier: 1) }.to raise_error ActiveRecord::RecordInvalid, /Multiplier must be greater than or equal to 2/
      expect { FactoryGirl.create(:play, multiplier: -1) }.to raise_error ActiveRecord::RecordInvalid, /Multiplier must be greater than or equal to 2/
      expect { FactoryGirl.create(:play, multiplier: 5.5) }.to raise_error ActiveRecord::RecordInvalid, /Multiplier must be an integer/
    end
  end

  describe '#earned_coins' do
    let(:play) { FactoryGirl.create(:play) }

    context 'when the play has a prize' do
      let!(:table_ranking) { FactoryGirl.create(:table_ranking, play: play, position: 10, earned_coins: 10) }

      it 'returns the coins that the user earned in that table' do
        expect(play.earned_coins).to eq 10
      end
    end

    context 'when the play did not have a table ranking' do
      it 'returns N/A when no block is given' do
        expect(play.earned_coins).to eq 'N/A'
      end

      it 'returns calls the given block if given' do
        earned_coins = play.earned_coins { 'unknown' }

        expect(earned_coins).to eq 'unknown'
      end
    end
  end

  describe '#position' do
    let(:play) { FactoryGirl.create(:play) }

    context 'when the play has a table ranking' do
      let!(:table_ranking) { FactoryGirl.create(:table_ranking, play: play, position: 10) }

      it 'returns the coins that the user earned in that table' do
        expect(play.position).to eq 10
      end
    end

    context 'when the play did not have a table ranking' do
      it 'returns N/A when no block is given' do
        expect(play.position).to eq 'N/A'
      end

      it 'returns calls the given block if given' do
        position = play.position { -1 }

        expect(position).to eq -1
      end
    end
  end

  describe '#points_for_ranking' do
    let(:play) { FactoryGirl.create(:play, points: 10) }

    context 'when the play has a table ranking' do
      let!(:table_ranking) { FactoryGirl.create(:table_ranking, play: play, position: 10, points: 200) }

      it 'returns the points for the ranking that the user earned in that table' do
        expect(play.points_for_ranking).to eq 200
      end
    end

    context 'when the play did not have a table ranking' do
      it 'returns N/A when no block is given' do
        expect(play.points_for_ranking).to eq 'N/A'
      end

      it 'returns calls the given block if given' do
        points_for_ranking = play.points_for_ranking { 0 }

        expect(points_for_ranking).to eq 0
      end
    end
  end

  describe '#points' do
    context 'when the play has some points' do
      let!(:play) { FactoryGirl.create(:play, points: 10) }

      it 'returns the points for the ranking that the user earned in that table' do
        expect(play.points).to eq 10
      end
    end

    context 'when the play does not have any points assigned yet' do
      let!(:play) { FactoryGirl.create(:play) }

      it 'returns nil when no block is given' do
        expect(play.points).to be_nil
      end

      it 'returns calls the given block if given' do
        points = play.points { 'N/A' }

        expect(points).to eq 'N/A'
      end
    end
  end
end
