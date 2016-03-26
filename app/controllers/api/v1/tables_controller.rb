class Api::V1::TablesController < Api::BaseController
  def index
    @tables = Table.all
  end

  def show
    @table = Table.includes(matches: [{ local_team: :players }, { visitor_team: :players }]).find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e }, status: 422
  end
end
