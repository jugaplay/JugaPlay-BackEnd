class Api::V1::PlaysController < Api::BaseController
  def index
    @plays = Play.where(user: current_user).limit(params[:to]).offset(params[:from])
  end
end