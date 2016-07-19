class Registration < ActiveRecord::Base
  belongs_to :registration_status
  belongs_to :request
  belongs_to :guest_user , :class_name => 'User'
end
