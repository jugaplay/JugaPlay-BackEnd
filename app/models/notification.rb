class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notification_type
  
  validates_presence_of :notification_type, :user, :title
  
 
end
