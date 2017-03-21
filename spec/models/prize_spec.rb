require 'spec_helper'

describe Prize do
  let(:user) { FactoryGirl.create(:user) }
  let(:table) { FactoryGirl.create(:table) }

  describe 'validations' do
    it 'must belongs to a user' do
      expect { Prize.create!(user: nil) }.to raise_error ActiveRecord::RecordInvalid, /User can't be blank/
    end

    it 'must belongs to a unique table per user' do
      Prize.create!(user: user, table: table, coins: 1)

      expect { Prize.create!(user: user, table: nil) }.to raise_error ActiveRecord::RecordInvalid, /Table can't be blank/
      expect { Prize.create!(user: user, table: table) }.to raise_error ActiveRecord::RecordInvalid, /Table has already been taken/
    end

    it 'must have an integer positive number of coins' do
      wallet = user.wallet

      expect { Prize.create!(user: user, table: table, coins: 10) }.not_to raise_error

      expect { Prize.create!(user: user, table: table, coins: nil) }.to raise_error ActiveRecord::RecordInvalid, /Coins is not a number/
      expect { Prize.create!(user: user, table: table, coins: -1) }.to raise_error ActiveRecord::RecordInvalid, /Coins must be greater than or equal to 0/
      expect { Prize.create!(user: user, table: table, coins: 1.5) }.to raise_error ActiveRecord::RecordInvalid, /Coins must be an integer/
    end
  end
end
