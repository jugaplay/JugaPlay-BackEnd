require 'spec_helper'

describe PlaysHistory do
  let(:plays_history) { PlaysHistory.new }
  let(:user_1) { FactoryGirl.create(:user, first_name: 'User 1') }
  let(:user_2) { FactoryGirl.create(:user, first_name: 'User 2') }
  let(:table_A) { FactoryGirl.create(:table, title: 'Table A') }
  let(:table_B) { FactoryGirl.create(:table, title: 'Table B') }

  let!(:play_by_user_1_in_table_A) { FactoryGirl.create(:play, user: user_1, table: table_A, points: 100) }
  let!(:play_by_user_2_in_table_A) { FactoryGirl.create(:play, user: user_2, table: table_A, points: 100) }
  let!(:play_by_user_1_in_table_B) { FactoryGirl.create(:play, user: user_1, table: table_B, points: 100) }
  let!(:play_by_user_2_in_table_B) { FactoryGirl.create(:play, user: user_2, table: table_B, points: 20) }

  describe '#of_table' do
    context 'when no table is given' do
      let(:table) { nil }

      it 'returns all the plays' do
        plays = plays_history.of_table(table).all

        expect(plays).to have(4).items
        expect(plays).to include play_by_user_1_in_table_A
        expect(plays).to include play_by_user_2_in_table_A
        expect(plays).to include play_by_user_1_in_table_B
        expect(plays).to include play_by_user_2_in_table_B
      end
    end

    context 'when a table is given' do
      let(:table) { table_A }

      it 'returns all the plays that belongs to that table' do
        plays = plays_history.of_table(table).all

        expect(plays).to have(2).items
        expect(plays).to include play_by_user_1_in_table_A
        expect(plays).to include play_by_user_2_in_table_A
      end
    end
  end

  describe '#made_by' do
    context 'when no user is given' do
      let(:user) { nil }

      it 'returns all the plays' do
        plays = plays_history.made_by(user).all

        expect(plays).to have(4).items
        expect(plays).to include play_by_user_1_in_table_A
        expect(plays).to include play_by_user_2_in_table_A
        expect(plays).to include play_by_user_1_in_table_B
        expect(plays).to include play_by_user_2_in_table_B
      end
    end

    context 'when a user is given' do
      let(:user) { user_1 }

      context 'when it is not filtered by table' do
        it 'returns all the plays made by that user' do
          plays = plays_history.made_by(user).all

          expect(plays).to have(2).items
          expect(plays).to include play_by_user_1_in_table_A
          expect(plays).to include play_by_user_1_in_table_B
        end
      end

      context 'when it is also filtered by table' do
        it 'returns all the plays made by that user in that table' do
          plays = plays_history.of_table(table_A).made_by(user).all

          expect(plays).to have(1).items
          expect(plays).to include play_by_user_1_in_table_A
        end
      end
    end
  end

  describe '#highest_scores' do
    context 'when no user or table are given' do
      it 'returns the highest plays of all the history' do
        plays = plays_history.highest_scores.all

        expect(plays).to have(3).items
        expect(plays).to include play_by_user_1_in_table_A
        expect(plays).to include play_by_user_2_in_table_A
        expect(plays).to include play_by_user_1_in_table_B
      end
    end

    context 'when a user is given' do
      let(:user) { user_1 }

      context 'when it is not filtered by table' do
        it 'returns the plays with highers scores of that user' do
          plays = plays_history.made_by(user).highest_scores.all

          expect(plays).to have(2).items
          expect(plays).to include play_by_user_1_in_table_A
          expect(plays).to include play_by_user_1_in_table_B
        end
      end

      context 'when it is also filtered by table' do
        it 'returns the plays with highers scores of that user in that table' do
          plays = plays_history.of_table(table_A).made_by(user).highest_scores.all

          expect(plays).to have(1).items
          expect(plays).to include play_by_user_1_in_table_A
        end
      end
    end

    context 'when a table is given' do
      it 'returns all the plays made by that user' do
        plays = plays_history.of_table(table_A).highest_scores.all

        expect(plays).to have(2).items
        expect(plays).to include play_by_user_1_in_table_A
        expect(plays).to include play_by_user_2_in_table_A
      end
    end
  end
end
