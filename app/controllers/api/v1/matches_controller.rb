class Api::V1::MatchesController < Api::BaseController
  def index
    @matches = Match.joins(:tables).where(tables: { id: params[:table_id] })
  end
end
