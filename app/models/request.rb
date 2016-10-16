class Request < ActiveRecord::Base
  belongs_to :request_type
  belongs_to :host_user , class_name: 'User'
  has_many :invitations
  
  validates :request_type, presence: true
  validates :host_user, presence: true
end
