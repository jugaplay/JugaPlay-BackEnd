require 'spec_helper'

describe Player do
  describe 'validations' do
    it 'must have a first name' do
      expect { FactoryGirl.create(:player, first_name: 'Carlos') }.not_to raise_error

      expect { FactoryGirl.create(:player, first_name: nil) }.to raise_error ActiveRecord::RecordInvalid, /First name can't be blank/
    end

    it 'must have a last name' do
      expect { FactoryGirl.create(:player, last_name: 'Perez') }.not_to raise_error

      expect { FactoryGirl.create(:player, last_name: nil) }.to raise_error ActiveRecord::RecordInvalid, /Last name can't be blank/
    end

    it 'must have a description' do
      expect { FactoryGirl.create(:player, description: 'a description') }.not_to raise_error

      expect { FactoryGirl.create(:player, description: nil) }.to raise_error ActiveRecord::RecordInvalid, /Description can't be blank/
    end

    it 'must have a birthday' do
      expect { FactoryGirl.create(:player, birthday: Date.today) }.not_to raise_error

      expect { FactoryGirl.create(:player, birthday: nil) }.to raise_error ActiveRecord::RecordInvalid, /Birthday can't be blank/
    end

    it 'must have a weight greater than 0' do
      expect { FactoryGirl.create(:player, weight: rand(100)) }.not_to raise_error

      expect { FactoryGirl.create(:player, weight: 0) }.to raise_error ActiveRecord::RecordInvalid, /Weight must be greater than 0/
      expect { FactoryGirl.create(:player, weight: -1) }.to raise_error ActiveRecord::RecordInvalid, /Weight must be greater than 0/
      expect { FactoryGirl.create(:player, weight: nil) }.to raise_error ActiveRecord::RecordInvalid, /Weight can't be blank/
    end

    it 'must have a height' do
      expect { FactoryGirl.create(:player, height: Faker::Number.between(1,2)) }.not_to raise_error

      expect { FactoryGirl.create(:player, height: 0) }.to raise_error ActiveRecord::RecordInvalid, /Height must be greater than 0/
      expect { FactoryGirl.create(:player, height: -1) }.to raise_error ActiveRecord::RecordInvalid, /Height must be greater than 0/
      expect { FactoryGirl.create(:player, height: nil) }.to raise_error ActiveRecord::RecordInvalid, /Height can't be blank/
    end

    it 'must have a valid nationality' do
      expect { FactoryGirl.create(:player, nationality: Country::ALL.sample) }.not_to raise_error

      expect { FactoryGirl.create(:player, nationality: nil) }.to raise_error ActiveRecord::RecordInvalid, /Nationality can't be blank/
      expect { FactoryGirl.create(:player, nationality: 'an invalid country') }.to raise_error ActiveRecord::RecordInvalid, /Nationality is not included in the list/
    end

    it 'must have a valid position' do
      expect { FactoryGirl.create(:player, position: Position::ALL.sample) }.not_to raise_error

      expect { FactoryGirl.create(:player, position: nil) }.to raise_error ActiveRecord::RecordInvalid, /Position can't be blank/
      expect { FactoryGirl.create(:player, position: 'an invalid position') }.to raise_error ActiveRecord::RecordInvalid, /Position is not included in the list/
    end

    it 'must be unique between teams' do
      player = FactoryGirl.create(:player)

      expect { FactoryGirl.create(:player, first_name: player.first_name, last_name: player.last_name, position: player.position, team: player.team) }.to raise_error ActiveRecord::RecordInvalid, /Team has already been taken/
    end
  end

  describe '#team_name_if_none' do
    let(:player) { FactoryGirl.create(:player, team: team) }

    context 'when the player belongs to a team' do
      let(:team) { FactoryGirl.create(:team) }

      it 'returns the team name' do
        expect(player.team_name_if_none { 'N/A' }).to eq team.name
      end
    end

    context 'when the player does not belong to a team' do
      let(:team) { nil }

      it 'evaluates the given block' do
        expect(player.team_name_if_none { 'N/A' }).to eq 'N/A'
      end
    end
  end
end
