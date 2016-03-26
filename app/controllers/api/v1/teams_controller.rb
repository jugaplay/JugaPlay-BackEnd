class Api::V1::TeamsController < Api::BaseController
  def show
    @team = Team.includes(:players).find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e }, status: 422
  end
end
