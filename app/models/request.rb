class Request < ActiveRecord::Base
  belongs_to :request_status
  belongs_to :request_type
  belongs_to :host_user , :class_name => 'User'
  belongs_to :guest_user, :class_name => 'User'
  
  validates :won_coins, numericality: { greater_than_or_equal_to: 0, allow_nil: false, only_integer: true }
 
  
end
