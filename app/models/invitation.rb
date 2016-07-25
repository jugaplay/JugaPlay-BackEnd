class Invitation < ActiveRecord::Base
  belongs_to :invitation_status
  belongs_to :request
  belongs_to :guest_user , :class_name => 'User',  required: false
  
  validates :guest_user, uniqueness: { scope: [:request] }
end