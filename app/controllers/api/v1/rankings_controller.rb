class Api::V1::RankingsController < Api::BaseController
  def index
    @rankings = Ranking.where(tournament_id: params[:tournament_id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e }, status: 422
  end
end
