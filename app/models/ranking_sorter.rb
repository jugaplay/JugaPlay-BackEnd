class RankingSorter
  def initialize(tournament)
    validate_tournament(tournament)
    @tournament = tournament
    @update_queries = []
  end

  def call
    prepare_rankings_to_update
    ActiveRecord::Base.connection.execute(update_queries.join(';'))
  end

  private
  attr_reader :tournament, :update_queries

  def prepare_rankings_to_update
    sorted_tournament_rankings.each_with_index do |ranking, i|
      update_queries.unshift "UPDATE rankings SET position = -#{i + 1} WHERE id = #{ranking.id}"
      update_queries.push "UPDATE rankings SET position = #{i + 1} WHERE id = #{ranking.id}"
    end
  end

  def sorted_tournament_rankings
    @sorted_tournament_rankings ||= tournament_ranking.joins(:user).order(points: :desc).merge(User.ordered)
  end

  def tournament_ranking
    @tournament_ranking ||= Ranking.for_tournament(tournament)
  end

  def validate_tournament(tournament)
    fail ArgumentError, 'A tournament must be given' unless tournament.present? and tournament.is_a?(Tournament)
  end
end
