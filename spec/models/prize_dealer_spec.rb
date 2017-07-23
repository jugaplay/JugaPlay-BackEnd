require 'spec_helper'

describe PrizeDealer do
  let(:prize_dealer) { PrizeDealer.new(table) }

  context 'for public tables' do
    let(:table) { FactoryGirl.create(:table, prizes: prizes) }

    context 'when there are two users playing' do
      let(:first_user) { FactoryGirl.create(:user, :without_coins) }
      let(:second_user) { FactoryGirl.create(:user, :without_coins) }

      let!(:first_user_table_ranking) { FactoryGirl.create(:table_ranking, :for_user_and_table, table: table, user: first_user, position: first_user_position) }
      let!(:second_user_table_ranking) { FactoryGirl.create(:table_ranking, :for_user_and_table, table: table, user: second_user, position: second_user_position) }

      context 'when there the users have different positions' do
        let(:first_user_position) { 1 }
        let(:second_user_position) { 2 }

        context 'when there are no coins' do
          let(:prizes) { [] }

          context 'when there was no multiplier bet' do
            it 'does not dispense coins for any user' do
              prize_dealer.call

              expect(first_user_table_ranking.reload.prize).to eq 0.coins
              expect(first_user_table_ranking.reload.prize).to eq 0.coins
            end
          end

          context 'when the first user has bet a multiplier by 2' do
            before { first_user_table_ranking.play.multiply_by!(2) }

            it 'does not dispense coins for any user' do
              prize_dealer.call

              expect(first_user_table_ranking.reload.prize).to eq 0.coins
              expect(first_user_table_ranking.reload.prize).to eq 0.coins
            end
          end
        end

        context 'when there are coins for one user' do
          let(:prizes) { [100.coins] }

          context 'when there was no multiplier bet' do
            it 'gives the coins to the first user' do
              prize_dealer.call

              expect(first_user.reload.coins).to eq 100.coins
              expect(first_user_table_ranking.reload.prize).to eq 100.coins

              expect(second_user.reload.coins).to eq 0.coins
              expect(second_user_table_ranking.reload.prize).to eq 0.coins
            end
          end

          context 'when the first user has bet a multiplier by 2' do
            before { first_user_table_ranking.play.multiply_by!(2) }

            it 'gives the coins to the first user multiplied by 2' do
              prize_dealer.call

              expect(first_user.reload.coins).to eq 200.coins
              expect(first_user_table_ranking.reload.prize).to eq 200.coins

              expect(second_user.reload.coins).to eq 0.coins
              expect(second_user_table_ranking.reload.prize).to eq 0.coins
            end
          end
        end

        context 'when there are coins for two users' do
          let(:prizes) { [100.coins, 20.coins] }

          context 'when there was no multiplier bet' do
            it 'gives the first position coins to the first user and the second position coins to the second user' do
              prize_dealer.call

              expect(first_user.reload.coins).to eq 100.coins
              expect(first_user_table_ranking.reload.prize).to eq 100.coins

              expect(second_user.reload.coins).to eq 20.coins
              expect(second_user_table_ranking.reload.prize).to eq 20.coins
            end
          end

          context 'when the first user has bet a multiplier by 2' do
            before { first_user_table_ranking.play.multiply_by!(2) }

            it 'gives the coins to the first user multiplied by 2' do
              prize_dealer.call

              expect(first_user.reload.coins).to eq 200.coins
              expect(first_user_table_ranking.reload.prize).to eq 200.coins

              expect(second_user.reload.coins).to eq 20.coins
              expect(second_user_table_ranking.reload.prize).to eq 20.coins
            end
          end
        end
      end

      context 'when there the users have the same positions' do
        let(:first_user_position) { 1 }
        let(:second_user_position) { 1 }

        context 'when there are no coins' do
          let(:prizes) { [] }

          context 'when there was no multiplier bet' do
            it 'does not give coins to any user' do
              prize_dealer.call

              expect(first_user_table_ranking.reload.prize).to eq 0.coins
              expect(first_user_table_ranking.reload.prize).to eq 0.coins
            end
          end

          context 'when the first user has bet a multiplier by 2' do
            before { first_user_table_ranking.play.multiply_by!(2) }

            it 'does not dispense coins for any user' do
              prize_dealer.call

              expect(first_user_table_ranking.reload.prize).to eq 0.coins
              expect(first_user_table_ranking.reload.prize).to eq 0.coins
            end
          end
        end

        context 'when there is a prize for one user' do
          let(:prizes) { [100.coins] }

          context 'when there was no multiplier bet' do
            it 'divides the first position coins between the two users' do
              prize_dealer.call

              expect(first_user.reload.coins).to eq 50.coins
              expect(first_user_table_ranking.reload.prize).to eq 50.coins

              expect(second_user.reload.coins).to eq 50.coins
              expect(second_user_table_ranking.reload.prize).to eq 50.coins
            end
          end

          context 'when the first user has bet a multiplier by 2' do
            before { first_user_table_ranking.play.multiply_by!(2) }

            it 'divides the first position coins between the two users, but the first users multiply it by 2' do
              prize_dealer.call

              expect(first_user.reload.coins).to eq 100.coins
              expect(first_user_table_ranking.reload.prize).to eq 100.coins

              expect(second_user.reload.coins).to eq 50.coins
              expect(second_user_table_ranking.reload.prize).to eq 50.coins
            end
          end
        end

        context 'when there are prizes for two users' do
          let(:prizes) { [100.coins, 20.coins] }

          context 'when there was no multiplier bet' do
            it 'divides the first and second position coins between the two users' do
              prize_dealer.call

              expect(first_user.reload.coins).to eq 60.coins
              expect(first_user_table_ranking.reload.prize).to eq 60.coins

              expect(second_user.reload.coins).to eq 60.coins
              expect(second_user_table_ranking.reload.prize).to eq 60.coins
            end
          end

          context 'when the first user has bet a multiplier by 2' do
            before { first_user_table_ranking.play.multiply_by!(2) }

            it 'divides the first and second position coins between the two users, but the first users multiply it by 2' do
              prize_dealer.call

              expect(first_user.reload.coins).to eq 120.coins
              expect(first_user_table_ranking.reload.prize).to eq 120.coins

              expect(second_user.reload.coins).to eq 60.coins
              expect(second_user_table_ranking.reload.prize).to eq 60.coins
            end
          end
        end

        context 'when there are prizes for three users' do
          let(:prizes) { [100.coins, 20.coins, 10.coins] }

          it 'divides the first and second position coins between the two users' do
            prize_dealer.call

            expect(first_user.reload.coins).to eq 60.coins
            expect(first_user_table_ranking.reload.prize).to eq 60.coins

            expect(second_user.reload.coins).to eq 60.coins
            expect(second_user_table_ranking.reload.prize).to eq 60.coins
          end
        end
      end
    end
  end

  context 'for private tables' do
    let(:group) { FactoryGirl.create(:group, :with_3_users_without_coins) }
    let(:table) { FactoryGirl.create(:table, entry_cost: 10.coins, group: group) }

    let(:users) { [first_user, second_user] }
    let(:first_user) { group.users.first }
    let(:second_user) { group.users.second }

    context 'when some users have played' do
      context 'when there are two of the three users of the group playing' do
        let(:first_user_play) { FactoryGirl.create(:play, table: table, user: first_user, cost: table.entry_cost) }
        let(:second_user_play) { FactoryGirl.create(:play, table: table, user: second_user, cost: table.entry_cost) }

        let!(:first_user_table_ranking) { FactoryGirl.create(:table_ranking, play: first_user_play, position: first_user_position) }
        let!(:second_user_table_ranking) { FactoryGirl.create(:table_ranking, play: second_user_play, position: second_user_position) }

        context 'when there the users have different positions' do
          let(:first_user_position) { 1 }
          let(:second_user_position) { 2 }

          context 'when there was no multiplier bet' do
            it 'dispenses coins for the first user only' do
              prize_dealer.call

              expect(first_user.reload.coins).to eq 20.coins
              expect(first_user_table_ranking.reload.prize).to eq 20.coins

              expect(second_user.reload.coins).to eq 0.coins
              expect(second_user_table_ranking.reload.prize).to eq 0.coins
            end
          end

          context 'when the first user has bet a multiplier by 2' do
            before { first_user_play.multiply_by!(2) }

            it 'dispenses coins for the first user multiplied by 2' do
              prize_dealer.call

              expect(first_user.reload.coins).to eq 40.coins
              expect(first_user_table_ranking.reload.prize).to eq 40.coins

              expect(second_user.reload.coins).to eq 0.coins
              expect(second_user_table_ranking.reload.prize).to eq 0.coins
            end
          end
        end

        context 'when there the users have the same positions' do
          let(:first_user_position) { 1 }
          let(:second_user_position) { 1 }

          context 'when there was no multiplier bet' do
            it 'divides the first position coins between the two users' do
              prize_dealer.call

              expect(first_user.reload.coins).to eq 10.coins
              expect(first_user_table_ranking.reload.prize).to eq 10.coins

              expect(second_user.reload.coins).to eq 10.coins
              expect(second_user_table_ranking.reload.prize).to eq 10.coins
            end
          end

          context 'when the first user has bet a multiplier by 2' do
            before { first_user_play.multiply_by!(2) }

            it 'divides the first position coins between the two users, but the first users multiply it by 2' do
              prize_dealer.call

              expect(first_user.reload.coins).to eq 20.coins
              expect(first_user_table_ranking.reload.prize).to eq 20.coins

              expect(second_user.reload.coins).to eq 10.coins
              expect(second_user_table_ranking.reload.prize).to eq 10.coins
            end
          end
        end
      end
    end

    context 'when no one have played' do
      it 'does not fail' do
        expect { prize_dealer.call }.not_to raise_error

        expect(first_user.reload.coins).to eq 0.coins
        expect(second_user.reload.coins).to eq 0.coins
      end
    end
  end
end
