require 'spec_helper'

describe BetMultiplierCalculator do
  let(:calculator) { BetMultiplierCalculator.new }

  context 'given a play' do
    let(:play) { FactoryGirl.create(:play, user: user, table: table) }
    let(:user) { FactoryGirl.create(:user, :with_chips, chips: chips) }
    let(:table) { FactoryGirl.create(:table, multiplier_chips_cost: multiplier_chips_cost) }

    context 'when the multiplier chips cost is 10' do
      let(:multiplier_chips_cost) { 10 }

      context 'when the user tries to multiply by 1' do
        let(:multiplier) { 1 }
      end

      context 'when the user tries to multiply by 2' do
        let(:multiplier) { 2 }

        context 'when the user has enough chips' do
          let(:chips) { 20 }

          it 'multiplies the play and subtracts the chips from the user wallet' do
            calculator.call play, multiplier

            expect(user.chips).to eq 10
            expect(play.bet_multiplier).to eq 2
          end
        end

        context 'when the user does not have enough chips' do
          let(:chips) { 5 }

          it 'raises an error and does not multiply the play' do
            expect { calculator.call play, multiplier }.to raise_error UserDoesNotHaveEnoughChips

            expect(user.chips).to eq 5
            expect(play.bet_multiplier).to be_nil
          end
        end
      end
    end

    context 'when the multiplier chips cost is 0' do
      let(:multiplier_chips_cost) { 0 }
      let(:chips) { 10 }
      let(:multiplier) { 2 }

      it 'raises an error and does not multiply the play' do
        expect { calculator.call play, multiplier }.to raise_error TableDoesNotHaveAMultiplierChipsCostDefined

        expect(user.chips).to eq 10
        expect(play.bet_multiplier).to be_nil
      end
    end
  end
end
