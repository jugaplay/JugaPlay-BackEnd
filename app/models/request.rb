class Request < ActiveRecord::Base
  has_one :request_type
  belongs_to :host_user , :class_name => 'User'
  has_many :invitations
 
end
