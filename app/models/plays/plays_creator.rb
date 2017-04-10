class PlaysCreator
  def self.for(table)
    return PrivateTablePlayCreator.new(table) if table.private?
    PublicTablePlayCreator.new(table)
  end

  def initialize(table)
    @table = table
  end

  def create_play(user:, players:, bet: false)
    validate_table_is_opened
    validate_bet_coins(user, bet_coins(bet))
    validate_user_can_play(user)
    validate_all_players(players)
    create_play_with(players, user, bet_coins(bet))
  end

  protected
  attr_reader :table

  def bet_coins(bet)
    fail 'subclass responsibility'
  end

  def validate_user_can_play(user)
    fail 'subclass responsibility'
  end

  def create_play_with(players, user, bet_coins)
    user.pay_coins! bet_coins
    TEntryFee.create!(user: user, coins: bet_coins, table: table, detail: "Entrada a : #{table.title}") if bet_coins > 0
    Play.create!(user: user, table: table, players: players, bet_coins: bet_coins)
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
    raise TableIsClosed.for(table) unless (table.opened? && (table.start_time > (Time.now - 182.minutes)))
  end

  def validate_all_players(players)
    fail CanNotPlayWithNumberOfPlayers unless table.can_play_with_amount_of_players?(players)
    fail PlayWithDuplicatedPlayer unless players.map(&:id).count == players.map(&:id).uniq.count
    fail PlayerDoesNotBelongToTable unless table.include_all_players?(players)
  end
end
