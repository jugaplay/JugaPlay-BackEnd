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
    validate_user_can_pay(user, entry_cost(bet))
    validate_user_can_play(user)
    validate_all_players(players)
    create_play_with(players, user, entry_cost(bet), play_type(bet))
  end

  protected
  attr_reader :table

  def entry_cost(bet)
    fail 'subclass responsibility'
  end

  def validate_user_can_play(user)
    fail 'subclass responsibility'
  end

  def play_type(bet)
    fail 'subclass responsibility'
  end

  def create_play_with(players, user, entry_cost, play_type)
    user.pay! entry_cost
    TEntryFee.create!(user: user, coins: entry_cost.value, table: table, detail: "Entrada a : #{table.title}") if entry_cost.coins? && entry_cost > 0.coins
    play = Play.create!(user: user, table: table, cost: entry_cost, type: play_type)
    players.each_with_index { |player, index| PlayerSelection.create!(play: play, player: player, points: 0, position: index + 1) }
    play
  end

  def validate_user_has_not_played(user)
    fail UserHasAlreadyPlayedInThisTable if table.has_played?(user)
  end

  def validate_user_can_pay(user, money)
    raise UserDoesNotHaveEnoughMoney.for(money.currency) unless user.has_money?(money)
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
