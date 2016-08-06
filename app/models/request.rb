class Request < ActiveRecord::Base
  belongs_to :request_type
  belongs_to :host_user , :class_name => 'User'
  has_many :invitations
 
end
