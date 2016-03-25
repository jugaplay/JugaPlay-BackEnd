require 'spec_helper'

describe Team do
  describe 'validations' do
    it 'must have a unique name' do
      expect { FactoryGirl.create(:team, name: 'River') }.not_to raise_error

      expect { FactoryGirl.create(:team, name: 'River') }.to raise_error ActiveRecord::RecordInvalid, /Name has already been taken/
      expect { FactoryGirl.create(:team, name: nil) }.to raise_error ActiveRecord::RecordInvalid, /Name can't be blank/
    end

    it 'must have a unique short name' do
      expect { FactoryGirl.create(:team, short_name: 'RIV') }.not_to raise_error

      expect { FactoryGirl.create(:team, short_name: 'RIV') }.to raise_error ActiveRecord::RecordInvalid, /Short name has already been taken/
      expect { FactoryGirl.create(:team, short_name: nil) }.to raise_error ActiveRecord::RecordInvalid, /Short name can't be blank/
    end

    it 'must have a unique director' do
      director = FactoryGirl.create(:director)

      expect { FactoryGirl.create(:team, director: director) }.not_to raise_error

      expect { FactoryGirl.create(:team, director: director) }.to raise_error ActiveRecord::RecordInvalid, /Director has already been taken/
      expect { FactoryGirl.create(:team, director: nil) }.to raise_error ActiveRecord::RecordInvalid, /Director can't be blank/
    end

    it 'must have a description' do
      expect { FactoryGirl.create(:team, description: nil) }.to raise_error ActiveRecord::RecordInvalid, /Description can't be blank/

      expect { FactoryGirl.create(:team, description: 'a description') }.not_to raise_error
    end
  end

  describe '#has_player?' do
    let(:team) { FactoryGirl.create(:team) }
    let(:another_player) { FactoryGirl.create(:player) }

    context 'when it does not include the given player' do
      it 'returns false' do
        expect(team).not_to have_player(another_player)
      end
    end

    context 'when it includes the given player' do
      before { team.update_attributes(players: team.players + [another_player]) }

      it 'returns true' do
        expect(team).to have_player(another_player)
      end
    end
  end
end
