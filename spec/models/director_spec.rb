require 'spec_helper'

describe Director do
  describe 'validations' do
    it 'must have a first name' do
      expect { FactoryGirl.create(:director, first_name: nil) }.to raise_error ActiveRecord::RecordInvalid, /First name can't be blank/

      expect { FactoryGirl.create(:director, first_name: 'Carlos') }.not_to raise_error
    end

    it 'must have a last name' do
      expect { FactoryGirl.create(:director, last_name: nil) }.to raise_error ActiveRecord::RecordInvalid, /Last name can't be blank/

      expect { FactoryGirl.create(:director, last_name: 'Perez') }.not_to raise_error
    end

    it 'must have a description' do
      expect { FactoryGirl.create(:director, description: nil) }.to raise_error ActiveRecord::RecordInvalid, /Description can't be blank/

      expect { FactoryGirl.create(:director, description: 'a description') }.not_to raise_error
    end
  end
end
