class Api::V1::PlayersController < Api::BaseController
  def stats
    @player = Player.find(params[:id])
    @match = Match.find(params[:match_id])
    @player_stats = PlayerStats.for_player_in_match(@player, @match)
    render partial: 'api/v1/players/stats', locals: { player_stats: @player_stats, player: @player }
  end
end
