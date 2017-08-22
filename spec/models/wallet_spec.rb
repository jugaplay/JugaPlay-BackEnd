require 'spec_helper'

describe Wallet do
  let(:user) { FactoryGirl.create(:user) }

  describe 'validations' do
    it 'must belongs to a user' do
      expect { Wallet.create!(user: nil) }.to raise_error ActiveRecord::RecordInvalid, /User can't be blank/
    end

    it 'must have a positive number of coins' do
      wallet = user.wallet

      expect { wallet.update_attributes!(coins: 10.coins) }.not_to raise_error
      expect { wallet.update_attributes!(coins: 1.5.coins) }.not_to raise_error

      expect { wallet.update_attributes!(coins: nil) }.to raise_error ActiveRecord::RecordInvalid, /Given money must be coins/
      expect { wallet.update_attributes!(coins: -1) }.to raise_error ActiveRecord::RecordInvalid, /Given money must be coins/
    end

    it 'must have a positive number of chips' do
      wallet = user.wallet

      expect { wallet.update_attributes!(chips: 10.chips) }.not_to raise_error
      expect { wallet.update_attributes!(chips: 1.5.chips) }.not_to raise_error

      expect { wallet.update_attributes!(chips: nil) }.to raise_error ActiveRecord::RecordInvalid, /Given money must be chips/
      expect { wallet.update_attributes!(chips: -1) }.to raise_error ActiveRecord::RecordInvalid, /Given money must be chips/
    end

    it 'must belongs to a uniq user' do
      expect { Wallet.create!(user: user) }.to raise_error ActiveRecord::RecordInvalid, /User has already been taken/
    end

    it 'has 30 chips by default' do
      expect(user.wallet.chips).to eq 30.chips
    end
  end
end
