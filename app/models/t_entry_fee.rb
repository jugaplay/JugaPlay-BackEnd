class TEntryFee < ActiveRecord::Base
  belongs_to :user
  belongs_to :tournament
  belongs_to :table
  
  validates :coins, numericality: { greater_than_or_equal_to: 0, allow_nil: false, only_integer: true }
  validates :user, presence: true
  validates :detail, presence: true, length: { maximum: 500 }, allow_blank: false
  validate :tournament_xor_table



  private
	
	# Una entry fee debe estar asociada a una mesa o a un torneo
	
    def tournament_xor_table
      unless tournament.blank? ^ table.blank?
        errors.add(:base, "Specify a tournament or a table, not both")
      end
    end    
     
end
