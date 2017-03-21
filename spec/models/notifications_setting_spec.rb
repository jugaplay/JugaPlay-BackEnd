require 'spec_helper'

describe NotificationsSetting do
  describe 'validations' do
    it 'must have a unique user' do
      user = FactoryGirl.create(:user)

      expect { FactoryGirl.create(:notifications_setting, user: user) }.not_to raise_error

      expect { FactoryGirl.create(:notifications_setting, user: nil) }.to raise_error /User can't be blank/
      expect { FactoryGirl.create(:notifications_setting, user: user) }.to raise_error /User has already been taken/
    end

    it 'must have a whatsapp configuration' do
      expect { FactoryGirl.create(:notifications_setting, whatsapp: true) }.not_to raise_error

      expect { FactoryGirl.create(:notifications_setting, whatsapp: nil) }.to raise_error /Whatsapp is not included in the list/
    end

    it 'must have a facebook configuration' do
      expect { FactoryGirl.create(:notifications_setting, facebook: true) }.not_to raise_error

      expect { FactoryGirl.create(:notifications_setting, facebook: nil) }.to raise_error /Facebook is not included in the list/
    end

    it 'must have a sms configuration' do
      expect { FactoryGirl.create(:notifications_setting, sms: true) }.not_to raise_error

      expect { FactoryGirl.create(:notifications_setting, sms: nil) }.to raise_error /Sms is not included in the list/
    end

    it 'must have a mail configuration' do
      expect { FactoryGirl.create(:notifications_setting, mail: true) }.not_to raise_error

      expect { FactoryGirl.create(:notifications_setting, mail: nil) }.to raise_error /Mail is not included in the list/
    end

    it 'must have a push configuration' do
      expect { FactoryGirl.create(:notifications_setting, push: true) }.not_to raise_error

      expect { FactoryGirl.create(:notifications_setting, push: nil) }.to raise_error /Push is not included in the list/
    end
  end
end
