class User < ActiveRecord::Base
  ADMIN_EMAIL = 'admin@jugaplay.com'

  devise :database_authenticatable, :recoverable, :trackable, :validatable #, :lockable #, :confirmable
  devise :omniauthable, omniauth_providers: [:facebook]

  has_one :wallet, dependent: :destroy
  has_one :address_book, dependent: :destroy
  has_one :channel, dependent: :destroy

  has_many :plays, dependent: :destroy
  has_many :rankings, dependent: :destroy
  has_many :user_prizes
  has_many :notifications
  has_many :invitation_requests
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
    return_block = proc { return 0 }
    prize_of_table(table, &return_block).coins
  end

  def prize_of_table(table, &if_none_block)
    user_prizes.detect(if_none_block) { |prize| prize.comes_from_table?(table) }
  end

  def bet_coins_in_table(table, &if_none_block)
    return_block = proc { return if_none_block.call }
    plays.detect(return_block) { |play| play.table.eql? table }.bet_coins
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
