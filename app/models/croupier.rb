class Croupier
  def self.for(table)
    return PrivateTableCroupier.new(table) if table.private?
    PublicTableCroupier.new(table)
  end

  def initialize(table)
    @table = table
    @points_calculator = PlayPointsCalculator.new
    @winners_calculator = TableWinnersCalculator.new(table)
  end

  def play(user:, players:, bet: false)
    validate_table_is_opened
    validate_bet_coins(user, bet_coins(bet))
    validate_user_can_play(user)
    validate_all_players(players)
    create_play(players, user, bet_coins(bet))
  end

  def assign_scores(players_stats:)
    validate_players_stats(players_stats)
    calculate_play_points(players_stats)
    dispense_coins unless winner_users.empty?
    table.close!
  end

  protected
  attr_reader :table, :points_calculator, :winners_calculator, :play_ids_to_update, :play_data_to_update

  def create_play(players, user, bet_coins)
    fail 'subclass responsibility'
  end

  def dispense_coins
    fail 'subclass responsibility'
  end

  def validate_user_can_play(user)
    fail 'subclass responsibility'
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

  def plays
    Play.where(table: table)
  end

  def winner_users
    @winner_users ||= winners_calculator.call
  end

  def validate_user_did_not_play_yet(user)
    fail UserHasAlreadyPlayedInThisTable unless table.did_not_play?(user)
  end

  def validate_bet_coins(user, bet_coins)
    fail UserDoesNotHaveEnoughCoins unless user.has_coins?(bet_coins)
  end

  def validate_table_is_opened
    # TODO: Manejar time zones acá, esto no escala - El servidor esta atrasado 3 horas desde argentina
    # TODO falta agregar condicion de si ya finalizo el partido
    fail TableIsClosed unless (table.opened && (table.start_time > (Time.now - 182.minutes)))
  end

  def validate_all_players(players)
    fail CanNotPlayWithNumberOfPlayers unless table.can_play_with_amount_of_players?(players)
    fail PlayWithDuplicatedPlayer unless players.map(&:id).count == players.map(&:id).uniq.count
    fail PlayerDoesNotBelongToTable unless table.include_all_players?(players)
  end

  def validate_players_stats(players_stats)
    fail MissingPlayerStats if players_stats.nil? || players_stats.empty?
    fail PlayerDoesNotBelongToTable unless table.include_all_players?(players_stats.map(&:player))
  end
end
