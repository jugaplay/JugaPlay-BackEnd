class Api::V1::PlaysController < Api::BaseController
  def index
    @plays = Play.where(user: current_user).limit(params[:to]).offset(params[:from])
    @earn_coins = TPrize.where(user: current_user).sum("coins")
  end
end