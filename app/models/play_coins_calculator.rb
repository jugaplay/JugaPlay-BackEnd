class PlayCoinsCalculator
  
  def initialize(table)
    fail ArgumentError, 'A table must be given' if table.nil?
    @table, @winners = table, []
  end
    
  def call()
 	users_plays.each_with_index.map { |user_play, index| assign_coins(User.find(user_play.user_id), index + 1)}
  end



  private
    
  def users_plays
  	@cant_premios = @table.prizes.count
   # @winner_users_ids ||= @table.plays.order(points: :desc).limit(@table.prizes.count)
 	@winner_users_ids ||= @table.plays.order(points: :desc).joins(:user).
      joins("LEFT JOIN rankings ON (rankings.user_id = users.id AND rankings.tournament_id = #{ @table.tournament.id })").
      order('rankings.position ASC').merge(User.ordered).limit(@table.prizes.count)
 
  
  end
    
  
  def assign_coins(user, index)
  	
  	@prize = @table.prizes.find_by_position(index)
  	user.win_coins!(@prize.coins) 
  	
  	# Creacion de transaccion en t_prizes
  	TPrize.create!(detail: 'Premio por ganar en mesa', prize: @prize, user: user, coins: @prize.coins) 	
  	
  end
  
  
end
