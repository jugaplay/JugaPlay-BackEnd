class Play < ActiveRecord::Base
  belongs_to :user
  belongs_to :table
  has_and_belongs_to_many :players, unique: true

  validates_presence_of :user, :table, :players
  validates_uniqueness_of :user_id, scope: [:table]
  validates :bet_coins, presence: true, numericality: { only_integer: true, allow_nil: false, greater_than_or_equal_to: 0 }


  def involves_player?(player)
    players.include? player
  end
  
 	def prizes_of_player(user)
		@t_prize_id = Prize.joins(:t_prize).where("table_id= ? AND user_id= ?", self.table.id,user.id).pluck("t_prizes.id").first()
		if @t_prize_id.present?
			TPrize.where("user_id = ? AND id = ?", user.id, @t_prize_id).sum("coins")
		else
			0
		end
		
	end


end