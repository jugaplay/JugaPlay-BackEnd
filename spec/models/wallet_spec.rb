require 'spec_helper'

describe Wallet do
  let(:user) { FactoryGirl.create(:user) }

  describe 'validations' do
    it 'must belongs to a user' do
      expect { Wallet.create!(user: nil) }.to raise_error ActiveRecord::RecordInvalid, /User can't be blank/
    end

    it 'must have an integer positive number of coins' do
      wallet = user.wallet

      expect { wallet.update_attributes!(coins: 10) }.not_to raise_error
      expect { wallet.update_attributes!(coins: 1.5) }.not_to raise_error

      expect { wallet.update_attributes!(coins: nil) }.to raise_error ActiveRecord::RecordInvalid, /Coins is not a number/
      expect { wallet.update_attributes!(coins: -1) }.to raise_error ActiveRecord::RecordInvalid, /Coins must be greater than or equal to 0/
    end

    it 'must belongs to a uniq user' do
      expect { Wallet.create!(user: user) }.to raise_error ActiveRecord::RecordInvalid, /User has already been taken/
    end

    it 'has 10 coins by default' do
      expect(user.wallet.coins).to eq 10
    end
  end
end
