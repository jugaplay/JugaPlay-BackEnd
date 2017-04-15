class Api::V1::PlaysController < Api::BaseController
  PLAY_NOT_FOUND = 'No se encontró la jugada solicitada'

  def index
    @plays = Play.recent_finished_by(current_user).limit(params[:to]).offset(params[:from])
  end

  def show
    @play = current_user.plays.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found_error PLAY_NOT_FOUND
  end
end
