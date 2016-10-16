class Api::V1::PlaysController < Api::BaseController
  def index
    @plays = Play.recent_finished_by(current_user).limit(params[:to]).offset(params[:from])
  end
end
