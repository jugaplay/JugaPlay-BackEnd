class Api::V1::PlaysController < Api::BaseController

  def index
    @plays = Play.where(user: current_user).joins(:table).where("tables.opened = false").order("tables.start_time DESC").limit(params[:to]).offset(params[:from])
    
  end

end