class User < ActiveRecord::Base
  ADMIN_EMAIL = 'admin@jugaplay.com'

  devise :database_authenticatable, :recoverable, :trackable, :validatable #, :lockable #, :confirmable
  devise :omniauthable, omniauth_providers: [:facebook]

  has_many :notifications
  has_many :invitation_requests
  has_many :plays, dependent: :destroy
  has_many :table_rankings, through: :plays
  has_many :t_entry_fees, dependent: :destroy
  has_many :rankings, dependent: :destroy
  has_many :league_rankings, dependent: :destroy
  has_one :wallet, dependent: :destroy
  has_one :address_book, dependent: :destroy
  has_one :notifications_setting, dependent: :destroy
  has_and_belongs_to_many :groups, -> { uniq }
  has_and_belongs_to_many :explanations, before_add: :validates_explanation_already_exist

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :nickname, uniqueness: true, presence: true
  validates :email, uniqueness: true, if: proc { email.present? }
  validates :telephone, format: /\A\d+\Z/, uniqueness: true, if: proc { telephone.present? }
  validates :facebook_id, uniqueness: { scope: :provider }, if: proc { facebook_id.present? && provider.present? }

  scope :ordered, -> { order(created_at: :asc) }

  def name
    "#{first_name} #{last_name}"
  end

  def coins
    wallet.coins
  end

  def chips
    wallet.chips
  end

  def has_money?(money)
    wallet.has_money? money
  end

  def pay!(money)
    wallet.subtract! money
  end

  def win_money!(money)
    wallet.add! money
  end

  def ranking_on_tournament(tournament)
    rankings.find_by(tournament_id: tournament)
  end

  def needs_to_login_with_facebook?
    facebook_id.present? && !has_facebook_token?
  end

  def has_facebook_token?
    facebook_token.present?
  end

  def admin?
    email == ADMIN_EMAIL
  end

  private

  def validates_explanation_already_exist(explanation)
    raise ActiveRecord::Rollback if self.explanations.include? explanation
  end
end
