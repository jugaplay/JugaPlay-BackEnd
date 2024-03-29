class Group < ActiveRecord::Base
  has_one :group_invitation_token
  has_and_belongs_to_many :users, -> { uniq }

  validates :name, presence: true
  validates :users, length: { minimum: 1 }
  validate :unique_users

  def size
    users.size
  end

  def add user
    users << user unless has_user? user
  end

  def remove user
    users.delete user
  end

  def has_user? user
    users.include? user
  end

  def invitation_token
    group_invitation_token.token
  end

  private

  def unique_users
    errors[:base] << 'User has already been taken' unless users.size.eql? users.uniq.count
  end
end
