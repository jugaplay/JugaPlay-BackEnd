class Croupier
  def initialize(table)
    @table = table
    @points_calculator = PlayPointsCalculator.new
    @winners_calculator = TableWinnersCalculator.new(table)
  end

  def play(user:, players:, bet: false)
    bet_coins = bet ? table.entry_coins_cost : 0
    validate_user(user)
    validate_is_opened
    validate_all_players(players)
    validate_bet_coins(user, bet_coins)
    create_play(players, user, bet_coins)
  end

  def assign_scores(players_stats:)
    validate_players_stats(players_stats)
    calculate_play_points(players_stats)
    ranking_points_updater.call
    coins_dispenser.call
    table.close!
  end

  private
  attr_reader :table, :points_calculator, :winners_calculator, :play_ids_to_update, :play_data_to_update

  def create_play(players, user, bet_coins)
    user.pay_coins!(bet_coins)
    @detail = 'Entrada a : ' + table.title
    TEntryFee.create!(user: user, coins: bet_coins, detail: @detail, table: table ) if bet_coins > 0
    Play.create!(user: user, table: table, players: players, bet_coins: bet_coins)
  end

  def calculate_play_points(players_stats)
    @play_ids_to_update, @play_data_to_update = [], []
    plays.find_each { |play| update_data_for_play_with(play, players_stats) }
    Play.update(play_ids_to_update, play_data_to_update)
  end

  def update_data_for_play_with(play, players_stats)
    applicable_stats = players_stats.select { |player_stats| play.involves_player? (player_stats.player) }
    fail MissingPlayerStats if applicable_stats.empty?
    play_ids_to_update << play.id
    play_data_to_update << { points: points_calculator.call(table.table_rules, applicable_stats)}
  end

  def coins_dispenser
    @coins_dispenser ||= CoinsDispenser.new(table: table, users: winner_users)
  end

  def ranking_points_updater
    @ranking_points_updater ||= RankingPointsUpdater.new(tournament: table.tournament, points_for_winners: table.points_for_winners, users: winner_users)
  end

  def winner_users
    @winner_users ||= winners_calculator.call
  end

  def plays
    Play.where(table: table)
  end

  def validate_user(user)
    fail UserHasAlreadyPlayedInThisTable unless table.can_play_user?(user)
  end

  def validate_is_opened
    # TODO: Manejar time zones acá, esto no escala - El servidor esta atrasado 3 horas desde argentina
    # TODO falta agregar condicion de si ya finalizo el partido
    fail TableIsClosed unless (table.opened && (table.start_time > (Time.now - 182.minutes)))
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
