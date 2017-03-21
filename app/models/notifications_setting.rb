class NotificationsSetting < ActiveRecord::Base
  belongs_to :user

  validates :user, presence: true, uniqueness: true
  validates :sms, inclusion: { in: [true, false] }
  validates :mail, inclusion: { in: [true, false] }
  validates :push, inclusion: { in: [true, false] }
  validates :facebook, inclusion: { in: [true, false] }
  validates :whatsapp, inclusion: { in: [true, false] }
end
