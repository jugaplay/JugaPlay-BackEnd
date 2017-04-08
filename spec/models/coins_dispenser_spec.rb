require 'spec_helper'

describe CoinsDispenser do
  let(:coins_dispenser) { CoinsDispenser.new(table) }

  context 'for public tables' do
    let(:table) { FactoryGirl.create(:table, coins_for_winners: coins_for_winners) }

    context 'when there are two users playing' do
      let(:first_user) { FactoryGirl.create(:user, :without_coins) }
      let(:second_user) { FactoryGirl.create(:user, :without_coins) }

      let!(:first_user_table_ranking) { FactoryGirl.create(:table_ranking, :for_user_and_table, table: table, user: first_user, position: first_user_position) }
      let!(:second_user_table_ranking) { FactoryGirl.create(:table_ranking, :for_user_and_table, table: table, user: second_user, position: second_user_position) }

      context 'when there the users have different positions' do
        let(:first_user_position) { 1 }
        let(:second_user_position) { 2 }

        context 'when there are no coins' do
          let(:coins_for_winners) { [] }

          it 'does not dispense coins for any user' do
            coins_dispenser.call

            expect(first_user_table_ranking.reload.earned_coins).to eq 0
            expect(first_user_table_ranking.reload.earned_coins).to eq 0
          end
        end

        context 'when there are coins for one user' do
          let(:coins_for_winners) { [100] }

          it 'gives the coins to the first user' do
            coins_dispenser.call

            expect(first_user.reload.coins).to eq 100
            expect(first_user_table_ranking.reload.earned_coins).to eq 100

            expect(second_user.reload.coins).to eq 0
            expect(second_user_table_ranking.reload.earned_coins).to eq 0
          end
        end

        context 'when there are coins for two users' do
          let(:coins_for_winners) { [100, 20] }

          it 'gives the coins to the first user' do
            coins_dispenser.call

            expect(first_user.reload.coins).to eq 100
            expect(first_user_table_ranking.reload.earned_coins).to eq 100

            expect(second_user.reload.coins).to eq 20
            expect(second_user_table_ranking.reload.earned_coins).to eq 20
          end
        end
      end

      context 'when there the users have the same positions' do
        let(:first_user_position) { 1 }
        let(:second_user_position) { 1 }

        context 'when there are no coins' do
          let(:coins_for_winners) { [] }

          it 'does not dispense coins for any user' do
            coins_dispenser.call

            expect(first_user_table_ranking.reload.earned_coins).to eq 0
            expect(first_user_table_ranking.reload.earned_coins).to eq 0
          end
        end

        context 'when there are coins for one user' do
          let(:coins_for_winners) { [100] }

          it 'gives the coins to the first user' do
            coins_dispenser.call

            expect(first_user.reload.coins).to eq 50
            expect(first_user_table_ranking.reload.earned_coins).to eq 50

            expect(second_user.reload.coins).to eq 50
            expect(second_user_table_ranking.reload.earned_coins).to eq 50
          end
        end

        context 'when there are coins for two users' do
          let(:coins_for_winners) { [100, 20] }

          it 'divides the first and second position coins between the two users' do
            coins_dispenser.call

            expect(first_user.reload.coins).to eq 60
            expect(first_user_table_ranking.reload.earned_coins).to eq 60

            expect(second_user.reload.coins).to eq 60
            expect(second_user_table_ranking.reload.earned_coins).to eq 60
          end
        end

        context 'when there are coins for three users' do
          let(:coins_for_winners) { [100, 20, 10] }

          it 'divides the first and second position coins between the two users' do
            coins_dispenser.call

            expect(first_user.reload.coins).to eq 60
            expect(first_user_table_ranking.reload.earned_coins).to eq 60

            expect(second_user.reload.coins).to eq 60
            expect(second_user_table_ranking.reload.earned_coins).to eq 60
          end
        end
      end
    end
  end

  context 'for private tables' do
    let(:group) { FactoryGirl.create(:group, :with_3_users_without_coins) }
    let(:table) { FactoryGirl.create(:table, entry_coins_cost: 10, group: group) }

    context 'when there are two of the three users of the group playing' do
      let(:users) { [first_user, second_user] }
      let(:first_user) { group.users.first }
      let(:second_user) { group.users.second }

      let(:first_user_play) { FactoryGirl.create(:play, table: table, user: first_user, bet_coins: table.entry_coins_cost) }
      let(:second_user_play) { FactoryGirl.create(:play, table: table, user: second_user, bet_coins: table.entry_coins_cost) }

      let!(:first_user_table_ranking) { FactoryGirl.create(:table_ranking, play: first_user_play, position: first_user_position) }
      let!(:second_user_table_ranking) { FactoryGirl.create(:table_ranking, play: second_user_play, position: second_user_position) }

      context 'when there the users have different positions' do
        let(:first_user_position) { 1 }
        let(:second_user_position) { 2 }

        it 'dispenses coins for the first user only' do
          coins_dispenser.call

          expect(first_user.reload.coins).to eq 20
          expect(first_user_table_ranking.reload.earned_coins).to eq 20

          expect(second_user.reload.coins).to eq 0
          expect(second_user_table_ranking.reload.earned_coins).to eq 0
        end
      end

      context 'when there the users have the same positions' do
        let(:first_user_position) { 1 }
        let(:second_user_position) { 1 }

        it 'dispenses coins for the first user only' do
          coins_dispenser.call

          expect(first_user.reload.coins).to eq 10
          expect(first_user_table_ranking.reload.earned_coins).to eq 10

          expect(second_user.reload.coins).to eq 10
          expect(second_user_table_ranking.reload.earned_coins).to eq 10
        end
      end
    end
  end
end
