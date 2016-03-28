class Croupier
  def initialize(table)
    @table = table
    @points_calculator = PlayPointsCalculator.new
    @winners_calculator = TableWinnersCalculator.new(table)
  end

  def play(user:, players:, password:, bet: false)
    bet_coins = bet ? table.entry_coins_cost : 0
    validate_user(user)
	if table.has_password
	    validate_password(table,user,password)
	end
    validate_all_players(players)
    validate_bet_coins(user, bet_coins)
    create_play(players, user, bet_coins)
  end

  def assign_scores(players_stats:)
    validate_players_stats(players_stats)
    assign_points(players_stats)
  end

  private
  attr_reader :table, :points_calculator, :winners_calculator, :play_ids_to_update, :play_data_to_update

  def create_play(players, user, bet_coins)
    user.pay_coins!(bet_coins)
    Play.create!(user: user, table: table, players: players, bet_coins: bet_coins)
  end

  def assign_points(players_stats)
    @play_ids_to_update, @play_data_to_update = [], []
    plays.find_each { |play| update_data_for_play_with(play, players_stats) }
    Play.update(play_ids_to_update, play_data_to_update)
    ranking_points_updater.call
    table.update_attributes(opened: false)
  end

  def update_data_for_play_with(play, players_stats)
    applicable_stats = players_stats.select { |player_stats| play.involves_player? (player_stats.player) }
    fail MissingPlayerStats if applicable_stats.empty?
    play_ids_to_update << play.id
    play_data_to_update << { points: points_calculator.call(table.table_rules, applicable_stats) }
  end

  def plays
    Play.where(table: table)
  end

  def ranking_points_updater
    @ranking_points_updater ||= RankingPointsUpdater.new(
      tournament: table.tournament,
      points_for_winners: table.points_for_winners,
      users: winners_calculator.call
    )
  end

  def validate_user(user)
    fail UserHasAlreadyPlayedInThisTable unless table.can_play_user?(user)
  end

  def validate_password(table,user, password)  
    fail  IncorrectPasswordToPlay unless (((user.id + 500) * (table.id + 500) * table.id * user.id).to_s(32).upcase) .eql? password
  end
  
  def validate_all_players(players)
    fail CanNotPlayWithNumberOfPlayers unless table.can_play_with_amount_of_players?(players)
    fail PlayWithDuplicatedPlayer unless players.map(&:id).count == players.map(&:id).uniq.count
    fail PlayerDoesNotBelongToTable unless table.include_all_players?(players)
  end

  def validate_bet_coins(user, bet_coins)
    fail UserDoesNotHaveEnoughCoins unless user.has_coins?(bet_coins)
  end

  def validate_players_stats(players_stats)
    fail MissingPlayerStats if players_stats.nil? || players_stats.empty?
    fail PlayerDoesNotBelongToTable unless table.include_all_players?(players_stats.map(&:player))
  end
end
