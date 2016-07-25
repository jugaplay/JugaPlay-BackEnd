class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notification_type
end
