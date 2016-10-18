class Croupier
  def initialize(table)
    @table = table
    @points_calculator = PlayPointsCalculator.new
    @coins_calculator = PlayCoinsCalculator.new(table)
    @winners_calculator = TableWinnersCalculator.new(table)
  end

  def play(user:, players:, bet: false)
    bet_coins = bet ? table.entry_coins_cost : 0
    validate_user(user)
    validate_is_opened(table)
    validate_all_players(players)
    validate_bet_coins(user, bet_coins)
    create_play(players, user, bet_coins)
  end

  def assign_scores(players_stats:)
    validate_players_stats(players_stats)
    assign_points(players_stats) 
  end

  private
  attr_reader :table, :points_calculator,  :coins_calculator, :winners_calculator, :play_ids_to_update, :play_data_to_update

  def create_play(players, user, bet_coins)
    user.pay_coins!(bet_coins)
    @detail = 'Entrada a : ' + table.title
    TEntryFee.create!(user: user, coins: bet_coins, detail: @detail, table: table ) if bet_coins > 0
    Play.create!(user: user, table: table, players: players, bet_coins: bet_coins)
  end

  def assign_points(players_stats)
    
    # Se asignan puntos
    @play_ids_to_update, @play_data_to_update = [], []
    plays.find_each { |play| update_data_for_play_with(play, players_stats) }
    Play.update(play_ids_to_update, play_data_to_update) 
    
    # Se actualiza el ranking de usuarios de JugaPlay
    ranking_points_updater.call
    table.update_attributes(opened: false)
    
    # Se asignan monedas
    coins_calculator.call
    
  end


# Asigna los puntos ganados en cada jugada

  def update_data_for_play_with(play, players_stats)
    applicable_stats = players_stats.select { |player_stats| play.involves_player? (player_stats.player) }
    fail MissingPlayerStats if applicable_stats.empty?
    play_ids_to_update << play.id
    play_data_to_update << { points: points_calculator.call(table.table_rules, applicable_stats)}
  end
  
  
  def plays
    Play.where(table: table) # Todas las jugadas de la mesa 
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

  def validate_is_opened(table)  
    fail  TableIsClosed unless (table.opened && (table.start_time > (Time.now - 182.minutes))) # TODO falta agregar condicion de si ya finalizo el partido
    #fail  MatchHasStart unless (table.start_time > (Time.now - 182.minutes))   El servidor esta atrasado 3 horas desde argentina
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
