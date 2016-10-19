class Api::V1::CroupierController < Api::BaseController

  def play
    play = croupier.play(user: current_user, players: players, bet: bet?)
    render partial: 'api/v1/plays/play', locals: { play: play }
  rescue ActiveRecord::RecordNotFound, PlayWithDuplicatedPlayer, PlayerDoesNotBelongToTable,
         UserDoesNotHaveEnoughCoins, UserHasAlreadyPlayedInThisTable, CanNotPlayWithNumberOfPlayers => error
    render_json_errors error.message
  end

  private

  def croupier
    Croupier.new(table)
  end

  def table
    @table ||= Table.find(params[:table_id])
  end

  def players
    @players ||= Player.where(id: params[:player_ids])
  end

  def bet?
    @bet ||= !!params[:bet]
  end
end
