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

    it 'must have unique players and at least one' do
      expect { FactoryGirl.create(:play, players: [FactoryGirl.create(:player)]) }.not_to raise_error

      expect { Play.create!(user: FactoryGirl.create(:user), table: FactoryGirl.create(:table)) }.to raise_error ActiveRecord::RecordInvalid, /Players can't be blank/
      expect { Play.last.players << Play.last.players.first }.to raise_error
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

    it 'can have no bet coins equal or greater than zero' do
      expect { FactoryGirl.create(:play, bet_coins: 0) }.not_to raise_error
      expect { FactoryGirl.create(:play, bet_coins: 5) }.not_to raise_error

      expect { FactoryGirl.create(:play, bet_coins: nil) }.to raise_error ActiveRecord::RecordInvalid, /Bet coins is not a number/
      expect { FactoryGirl.create(:play, bet_coins: -1) }.to raise_error ActiveRecord::RecordInvalid, /Bet coins must be greater than or equal to 0/
      expect { FactoryGirl.create(:play, bet_coins: 5.5) }.to raise_error ActiveRecord::RecordInvalid, /Bet coins must be an integer/
    end
  end
end
