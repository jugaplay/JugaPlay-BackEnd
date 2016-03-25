require 'spec_helper'

describe PlayerStats do
  describe 'validations' do
    it 'must have a player' do
      expect { FactoryGirl.create(:player_stats, player: FactoryGirl.create(:player)) }.not_to raise_error

      expect { FactoryGirl.create(:player_stats, player: nil) }.to raise_error ActiveRecord::RecordInvalid, /Player can't be blank/
    end

    it 'must have a match' do
      expect { FactoryGirl.create(:player_stats, match: FactoryGirl.create(:match)) }.not_to raise_error

      expect { FactoryGirl.create(:player_stats, match: nil) }.to raise_error ActiveRecord::RecordInvalid, /Match can't be blank/
    end

    it 'must have all features present an greater or equal to zero' do
      PlayerStats::FEATURES.each do |feature|
        expect { FactoryGirl.create(:player_stats, feature => rand(10)) }.not_to raise_error

        expect { FactoryGirl.create(:player_stats, feature => -1) }.to raise_error ActiveRecord::RecordInvalid, /must be greater than or equal to 0/
        expect { FactoryGirl.create(:player_stats, feature => nil) }.to raise_error ActiveRecord::RecordInvalid, /can't be blank/
      end
    end

    it 'must be unique for a player and a match' do
      player_stats = FactoryGirl.create(:player_stats)

      expect { FactoryGirl.create(:player_stats, player: player_stats.player, match: player_stats.match) }.to raise_error ActiveRecord::RecordInvalid, /Player has already been taken/
    end
  end
end
