class Registration < ActiveRecord::Base
  belongs_to :registration_status
  belongs_to :request
  belongs_to :guest_user , :class_name => 'User',  required: false
  
  validates :guest_user, uniqueness: { scope: [:request] }
end
