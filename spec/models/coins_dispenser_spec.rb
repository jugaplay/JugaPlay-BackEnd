require 'spec_helper'

describe CoinsDispenser do
  context 'when no users are given' do
    let(:coins_dispenser) { CoinsDispenser.new(table: 'table') }

    it 'raise an error' do
      expect { coins_dispenser }.to raise_error ArgumentError
    end
  end

  context 'when no coins for winners are given' do
    let(:coins_dispenser) { CoinsDispenser.new(users: ['user']) }

    it 'raise an error' do
      expect { coins_dispenser }.to raise_error ArgumentError
    end
  end

  context 'when a tablel and some users are given' do
    let(:table) { FactoryGirl.create(:table, coins_for_winners: coins_for_winners) }
    let(:coins_dispenser) { CoinsDispenser.new(users: users, table: table) }

    context 'when there are two users playing' do
      let(:users) { [first_user, second_user] }
      let(:first_user) { FactoryGirl.create(:user, :without_coins) }
      let(:second_user) { FactoryGirl.create(:user, :without_coins) }

      context 'when there are no coins' do
        let(:coins_for_winners) { [] }

        it 'does not dispense coins for any user' do
          coins_dispenser.call

          expect(UserPrize.count).to eq 0
          expect(first_user.reload.coins).to eq 0
          expect(second_user.reload.coins).to eq 0
        end
      end

      context 'when there are coins for one user' do
        let(:coins_for_winners) { [100] }

        it 'gives the coins to the first user' do
          coins_dispenser.call
          first_user_prize = UserPrize.last

          expect(UserPrize.count).to eq 1
          expect(first_user.reload.coins).to eq 100
          expect(second_user.reload.coins).to eq 0
          expect(first_user_prize.user).to eq first_user
          expect(first_user_prize.table).to eq table
          expect(first_user_prize.coins).to eq 100
        end
      end

      context 'when there are points for two users' do
        let(:coins_for_winners) { [100, 20] }

        it 'gives the coins to the first user' do
          coins_dispenser.call
          first_user_prize = UserPrize.first
          second_user_prize = UserPrize.second

          expect(UserPrize.count).to eq 2
          expect(first_user.reload.coins).to eq 100
          expect(first_user_prize.user).to eq first_user
          expect(first_user_prize.table).to eq table
          expect(first_user_prize.coins).to eq 100

          expect(second_user.reload.coins).to eq 20
          expect(second_user_prize.user).to eq second_user
          expect(second_user_prize.table).to eq table
          expect(second_user_prize.coins).to eq 20
        end
      end
    end
  end
end
