require 'spec_helper'

describe Tournament do
  describe 'validations' do
    it 'must have a unique name' do
      expect { FactoryGirl.create(:tournament, name: 'Clausura') }.not_to raise_error

      expect { FactoryGirl.create(:tournament, name: nil) }.to raise_error ActiveRecord::RecordInvalid, /Name can't be blank/
      expect { FactoryGirl.create(:tournament, name: 'Clausura') }.to raise_error ActiveRecord::RecordInvalid, /Name has already been taken/
    end
  end
end
