class Request < ActiveRecord::Base
  belongs_to :request_status
  belongs_to :request_types
  belongs_to :host_user
  belongs_to :guest_user
  
  validates :won_coins, numericality: { greater_than_or_equal_to: 0, allow_nil: false, only_integer: true }
 
  
end
