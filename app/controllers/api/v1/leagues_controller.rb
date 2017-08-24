class Api::V1::LeaguesController < Api::BaseController
  LEAGUE_NOT_FOUND = 'No se encontró la liga solicitada'

  def index
    @leagues = League.recent_first.page(params[:page])
    @total_items = League.recent_first.count
  end

  def show
    @league = League.find(params[:id])
    load_league_rankings
  rescue ActiveRecord::RecordNotFound
    render_not_found_error LEAGUE_NOT_FOUND
  end

  def actual
    @league = League.playing.last
    render_not_found_error LEAGUE_NOT_FOUND unless @league
    load_league_rankings
    render :show
  end

  private

  def load_league_rankings
    @league_rankings = @league.last_round_rankings.order(position: :asc).page(params[:page])
    @total_items = @league.amount_of_rankings
  end
end
