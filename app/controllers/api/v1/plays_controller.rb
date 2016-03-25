class Api::V1::PlaysController < Api::BaseController
  def index
    @plays = Play.where(user: current_user)
  end
end