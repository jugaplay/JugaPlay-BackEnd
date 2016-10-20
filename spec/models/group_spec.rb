require 'spec_helper'

describe Group do
  describe 'validations' do
    it 'can have a list of users without duplication' do
      first_user = FactoryGirl.create(:user)
      second_user = FactoryGirl.create(:user)

      group = FactoryGirl.create(:group)

      expect { group.update_attributes!(users: [first_user, second_user]) }.not_to raise_error
      expect { group.users << first_user }.to raise_error ActiveRecord::RecordNotUnique, /duplicate key/
      expect { group.update_attributes!(users: []) }.to raise_error ActiveRecord::RecordInvalid, /Users is too short/
    end
  end

  describe '#add' do
    let(:group) { FactoryGirl.create(:group) }

    context 'when the new user does not belong to the group' do
      let(:new_user) { FactoryGirl.create(:user) }

      it 'adds it to the group' do
        group.add new_user

        expect(group).to have_user new_user
      end
    end

    context 'when the new user belongs to the group' do
      let(:new_user) { group.users.first }

      it 'does not add it' do
        group_size = group.users.size

        group.add new_user

        expect(group.users.size).to eq group_size
        expect(group).to have_user new_user
      end
    end
  end

  describe '#remove' do
    let(:group) { FactoryGirl.create(:group) }

    context 'when the old user does not belong to the group' do
      let(:old_user) { FactoryGirl.create(:user) }

      it 'does not remove anyone' do
        group_size = group.users.size

        group.remove old_user

        expect(group.users.size).to eq group_size
        expect(group).not_to have_user old_user
      end
    end

    context 'when the new user belongs to the group' do
      let(:old_user) { group.users.first }

      it 'removes it from the group' do
        group.remove old_user

        expect(group).not_to have_user old_user
      end
    end
  end
end
