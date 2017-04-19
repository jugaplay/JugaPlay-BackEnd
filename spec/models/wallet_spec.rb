require 'spec_helper'

describe Wallet do
  let(:user) { FactoryGirl.create(:user) }

  describe 'validations' do
    it 'must belongs to a user' do
      expect { Wallet.create!(user: nil) }.to raise_error ActiveRecord::RecordInvalid, /User can't be blank/
    end

    it 'must have a positive number of coins' do
      wallet = user.wallet

      expect { wallet.update_attributes!(coins: 10) }.not_to raise_error
      expect { wallet.update_attributes!(coins: 1.5) }.not_to raise_error

      expect { wallet.update_attributes!(coins: nil) }.to raise_error ActiveRecord::RecordInvalid, /Coins is not a number/
      expect { wallet.update_attributes!(coins: -1) }.to raise_error ActiveRecord::RecordInvalid, /Coins must be greater than or equal to 0/
    end

    it 'must have a positive number of chips' do
      wallet = user.wallet

      expect { wallet.update_attributes!(chips: 10) }.not_to raise_error
      expect { wallet.update_attributes!(chips: 1.5) }.not_to raise_error

      expect { wallet.update_attributes!(chips: nil) }.to raise_error ActiveRecord::RecordInvalid, /Chips is not a number/
      expect { wallet.update_attributes!(chips: -1) }.to raise_error ActiveRecord::RecordInvalid, /Chips must be greater than or equal to 0/
    end

    it 'must belongs to a uniq user' do
      expect { Wallet.create!(user: user) }.to raise_error ActiveRecord::RecordInvalid, /User has already been taken/
    end

    it 'has 30 coins by default' do
      expect(user.wallet.coins).to eq 30
    end
  end
end
