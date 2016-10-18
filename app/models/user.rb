class User < ActiveRecord::Base
  ADMIN_EMAIL = 'admin@jugaplay.com'

  devise :database_authenticatable, :recoverable, :trackable, :validatable #, :lockable #, :confirmable
  devise :omniauthable, omniauth_providers: [:facebook]

  has_one :wallet, dependent: :destroy
  has_many :plays, dependent: :destroy
  has_many :rankings, dependent: :destroy
  belongs_to :invited_by, class_name: self.to_s, foreign_key: :invited_by_id
  has_many :user_prizes

  has_one :channel, dependent: :destroy
  has_many :requests
  has_many :notifications
  has_and_belongs_to_many :explanations, :before_add => :validates_explanation_alredy_exist

  validates_presence_of :first_name, :last_name
  validates :nickname, uniqueness: true, presence: true
  validates :email, uniqueness: true, if: proc { email.present? }
  validates :uid, uniqueness: { scope: :provider }, if: proc { uid.present? && provider.present? }
  validate :validate_not_invited_by_itself, on: :update

  scope :ordered, -> { order(created_at: :asc) }

  def name
    "#{first_name} #{last_name}"
  end

  def host
    User.find(self.invited_by_id)
  end

  def coins
    wallet.coins
  end

  def has_coins?(amount_of_coins)
    coins >= amount_of_coins
  end

  def pay_coins!(amount_of_coins)
    wallet.subtract_coins!(amount_of_coins)
  end

  def win_coins!(amount_of_coins)
    wallet.add_coins!(amount_of_coins)
  end

  def ranking_on_tournament(tournament)
    rankings.find_by(tournament_id: tournament)
  end

  def earned_coins_in_table(table)
    prize_of_table(table).map(&:coins).sum
  end

  def prize_of_table(table)
    user_prizes.select { |prize| prize.comes_from_table?(table) }
  end

  def play_of_table(table)
    plays.detect { |play| play.table == table }
  end

  def self.from_omniauth(auth,params)
    # TODO: Move all this shit outta here
    user_by_email = find_by(email: auth.info.email)

    if user_by_email.blank?
      if params['invited_by'].present?
        @host_user = User.find(params["invited_by"])
        @host_user.win_coins!(10)
      end
    end

    return user_by_email if user_by_email.present?
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.email = auth.info.email
      if auth.info.email.present?
        user.nickname = auth.info.email.split("@").first + Random.rand(999).to_s
      else
        user.nickname = auth.uid
      end
      user.password = Devise.friendly_token[0,20]
      user.image = auth.info.image
      user.wallet = Wallet.new
      if params['invited_by'].present?
        user.invited_by_id = @host_user.id
      end
    end
  end

  def admin?
    email == ADMIN_EMAIL
  end

  private

  def validate_not_invited_by_itself
    errors.add(:invited_by, 'Can not invite itself') if id.eql? invited_by_id
  end

  def validates_explanation_alredy_exist(explanation)
    raise ActiveRecord::Rollback if self.explanations.include? explanation
  end
end
