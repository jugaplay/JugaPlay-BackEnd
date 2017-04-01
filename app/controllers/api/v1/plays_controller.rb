class Api::V1::PlaysController < Api::BaseController
  PLAY_NOT_FOUND = 'No se encontró la jugada solicitada'

  def index
    @plays = Play.recent_finished_by(current_user).limit(params[:to]).offset(params[:from])
  end

  def show
    play { |error| return error }
  end

  def multiply
    multiplier = params[:multiplier].to_i
    play { |error| return error }
    play.bet_multiplier_by(multiplier)
    render :show
  rescue ActiveRecord::RecordInvalid => error
    render_json_error error.message
  end

  private

  def play(&not_found_block)
    @play ||= current_user.plays.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    not_found_block.call(render_not_found_error PLAY_NOT_FOUND)
  end
end
