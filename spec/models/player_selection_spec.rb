require 'spec_helper'

describe PlayerSelection do
  describe 'validations' do
    it 'must have a play' do
      expect { FactoryGirl.create(:player_selection, play: nil) }.to raise_error ActiveRecord::RecordInvalid, /Play can't be blank/
    end

    it 'must have a unique player' do
      another_player_selection = FactoryGirl.create(:player_selection)

      expect { FactoryGirl.create(:player_selection, player: nil) }.to raise_error ActiveRecord::RecordInvalid, /Player can't be blank/
      expect { FactoryGirl.create(:player_selection, player: another_player_selection.player, play: another_player_selection.play) }.to raise_error ActiveRecord::RecordInvalid, /Player has already been taken/
    end

    it 'must have a unique position per play' do
      another_player_selection = FactoryGirl.create(:player_selection)

      expect { FactoryGirl.create(:player_selection, position: nil) }.to raise_error ActiveRecord::RecordInvalid, /Position can't be blank/
      expect { FactoryGirl.create(:player_selection, position: another_player_selection.position, play: another_player_selection.play) }.to raise_error ActiveRecord::RecordInvalid, /Position has already been taken/
    end
  end
end
