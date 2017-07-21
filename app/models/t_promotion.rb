class TPromotion < ActiveRecord::Base
  belongs_to :user
  
  validates :coins, numericality: { greater_than_or_equal_to: 0, allow_nil: false }
  validates :user, presence: true
  validates :detail, presence: true, length: { maximum: 500 }, allow_blank: false
  validates :promotion_type, presence: true, allow_blank: false

  def self.friend_invitation!(attributes)
    create!(attributes.merge(promotion_type: 'friend-invitation', coins: Wallet::COINS_PER_INVITATION.value))
  end

  def self.registration!(user)
    create!(user: user, promotion_type: 'registration', coins: Wallet::COINS_PER_REGISTRATION.value, detail: 'Bienvenida a JugaPlay')
  end
end
