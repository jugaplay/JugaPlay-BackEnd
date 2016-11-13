class GroupInvitationToken < ActiveRecord::Base
  TOKEN_EXPIRATION = 2.days

  belongs_to :group

  validates :group, presence: true
  validates :expires_at, presence: true
  validates :token, presence: true, uniqueness: true, length: { is: 32 }

  def self.create_for_group!(group)
    new.tap do |invitation_token|
      invitation_token.group = group
      invitation_token.expires_at = DateTime.now
      invitation_token.build_new_token
    end
  end

  def update_if_expired!
    return self unless expired?
    build_new_token
    update_expiration
    self
  end

  def expired?
    expires_at < DateTime.now
  end

  def build_new_token
    update_attributes!(token: Devise.friendly_token(32))
  end

  def update_expiration
    update_attributes!(expires_at: DateTime.now + TOKEN_EXPIRATION)
  end
end
