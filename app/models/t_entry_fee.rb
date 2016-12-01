class TEntryFee < ActiveRecord::Base
  belongs_to :user
  belongs_to :table
  belongs_to :tournament

  validates :user, presence: true
  validates :detail, presence: true, length: { maximum: 500 }, allow_blank: false
  validates :coins, numericality: { greater_than_or_equal_to: 0, allow_nil: false, only_integer: true }
  validate :tournament_xor_table

  scope :by_date, -> { order(created_at: :desc) }

  private

  def tournament_xor_table
    # Una entry fee debe estar asociada a una mesa o a un torneo
    unless tournament.blank? ^ table.blank?
      errors.add(:base, 'Specify a tournament or a table, not both')
    end
  end
end
