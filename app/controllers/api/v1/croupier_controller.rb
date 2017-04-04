class Api::V1::CroupierController < Api::BaseController
  TABLE_NOT_FOUND = 'No se encontró la mesa indicada'

  def play
    play = plays_creator.create_play(user: current_user, players: players, bet: bet?)
    render partial: 'api/v1/plays/play', locals: { play: play }
  rescue ActiveRecord::RecordNotFound
    render_not_found_error TABLE_NOT_FOUND
  rescue PlayWithDuplicatedPlayer, PlayerDoesNotBelongToTable, CanNotPlayWithNumberOfPlayers, TableIsClosed,
      UserHasAlreadyPlayedInThisTable, UserDoesNotHaveEnoughCoins, UserDoesNotBelongToTableGroup => error
    render_json_errors error.message
  end

  private

  def plays_creator
    PlaysCreator.for(table)
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
