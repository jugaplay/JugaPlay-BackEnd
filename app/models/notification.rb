class Notification < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :user

  validates :user, presence: true
  validates :title, presence: true
  validates :type, presence: true, inclusion: { in: NotificationType::ALL }

  def self.result!(attributes)
    create!(attributes.merge(type: NotificationType::RESULT))
  end

  def self.challenge!(attributes)
    create!(attributes.merge(type: NotificationType::CHALLENGE))
  end

  def friend_invitation!(attributes)
    create!(attributes.merge(type: NotificationType::FRIEND_INVITATION))
  end
end
