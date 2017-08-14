class League < ActiveRecord::Base
  has_many :league_rankings

  serialize :prizes_values, Array
  as_enum :status, opened: 1, playing: 2, closed: 3

  validates :title, presence: true
  validates :image, presence: true
  validates :status, presence: true
  validates :starts_at, presence: true
  validates :description, presence: true
  validates :prizes_values, length: { minimum: 1 }
  validates :prizes_type, presence: true, inclusion: { in: Money::CURRENCIES }
  validates :periods, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :frequency_in_days, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates_each_in_array(:prizes_values) { validates_numericality_of :value, greater_than: 0, allow_nil: false }

  scope :opened, -> { openeds }
  scope :closed, -> { closeds }
  scope :playing, -> { playings }

  def frequency
    frequency_in_days.days
  end

  def pot_prize
    Money.new prizes_type, prizes_values.sum
  end

  def prize_for_position(position)
    prizes[position - 1] || Money.zero(prizes_type)
  end

  def prizes
    prizes_values.map { |prize| Money.new prizes_type, prize }
  end

  def prizes=(prizes)
    currency, values = MoneyListParser.new.parse!(prizes) do
      errors.add(:prizes, 'All prizes must be money with same currency')
      fail ActiveRecord::RecordInvalid.new self
    end
    self.prizes_type = currency
    self.prizes_values = values
  end
end
