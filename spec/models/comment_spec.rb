require 'spec_helper'

describe Comment do
  describe 'validations' do
    it 'must have a non-blank content with less than 500 characters' do
      expect { FactoryGirl.create(:comment, content: 'a content') }.not_to raise_error

      expect { FactoryGirl.create(:comment, content: nil) }.to raise_error /Content can't be blank/
      expect { FactoryGirl.create(:comment, content: '') }.to raise_error /Content can't be blank/
      expect { FactoryGirl.create(:comment, content: 'a' * 2001) }.to raise_error /maximum is 2000 characters/
    end
  end
end
