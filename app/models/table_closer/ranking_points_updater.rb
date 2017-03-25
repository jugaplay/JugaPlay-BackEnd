class RankingPointsUpdater
  def initialize(table)
    @table = table
    @ranking_ids_to_update, @ranking_points_to_update = [], []
  end

  def call
    Ranking.transaction do
      table.table_rankings.each { |table_ranking| create_ranking_or_build_points_for_update(table_ranking) }
      Ranking.update(ranking_ids_to_update, ranking_points_to_update)
    end
  end

  private
  attr_reader :table, :ranking_ids_to_update, :ranking_points_to_update

  def create_ranking_or_build_points_for_update(table_ranking)
    user_id = table_ranking.play.user_id
    existing_ranking = tournament_ranking.of_user(user_id).first
    points = points_for_tournament_ranking(table_ranking)
    return create_ranking(user_id, points) unless existing_ranking.present?
    add_points_to(existing_ranking, points)
  end

  def add_points_to(existing_ranking, points)
    existing_ranking_index = ranking_ids_to_update.find_index existing_ranking.id
    return build_points_for(existing_ranking, points) unless existing_ranking_index.present?
    ranking_points_to_update[existing_ranking_index][:points] += points
  end

  def build_points_for(existing_ranking, points)
    ranking_ids_to_update << existing_ranking.id
    ranking_points_to_update << { points: existing_ranking.points + points }
  end

  def create_ranking(user_id, points)
    @last_ranking_position = last_ranking_position + 1
    Ranking.create!(tournament: tournament, user_id: user_id, points: points, position: last_ranking_position)
  end

  def points_for_tournament_ranking(table_ranking)
    return 0 if table_ranking.private?
    table_ranking.points
  end

  def last_ranking_position
    @last_ranking_position ||= (tournament_ranking.maximum(:position) || 0)
  end

  def tournament_ranking
    @tournament_ranking ||= Ranking.for_tournament(tournament)
  end

  def tournament
    @tournament ||= table.tournament
  end
end
