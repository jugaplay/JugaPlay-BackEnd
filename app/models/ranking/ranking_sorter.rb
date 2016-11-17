class RankingSorter
  def initialize(tournament)
    validate_tournament(tournament)
    @tournament = tournament
    @new_rankings = []
  end

  def call
    build_new_rankings
    sorted_tournament_rankings.destroy_all
    Ranking.import(new_rankings)
  end

  private
  attr_reader :tournament, :new_rankings

  def build_new_rankings
    sorted_tournament_rankings.each_with_index do |ranking, i|
      new_ranking = ranking.clone
      new_ranking.position = i + 1
      new_rankings << new_ranking
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
