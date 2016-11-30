require 'spec_helper'

describe Notification do
  describe 'validations' do
    it 'must have any notification type' do
      expect { FactoryGirl.create(:notification, type: NotificationType::RESULT) }.not_to raise_error

      expect { FactoryGirl.create(:notification, type: nil) }.to raise_error /Type can't be blank/
      expect { FactoryGirl.create(:notification, type: '') }.to raise_error /Type can't be blank/
      expect { FactoryGirl.create(:notification, type: 'invalid') }.to raise_error /Type is not included in the list/
    end

    it 'must have a user' do
      expect { FactoryGirl.create(:notification, user: FactoryGirl.create(:user)) }.not_to raise_error

      expect { FactoryGirl.create(:notification, user: nil) }.to raise_error /User can't be blank/
    end

    it 'must have a title' do
      expect { FactoryGirl.create(:notification, title: 'a title') }.not_to raise_error

      expect { FactoryGirl.create(:notification, title: nil) }.to raise_error /Title can't be blank/
    end
  end
end
