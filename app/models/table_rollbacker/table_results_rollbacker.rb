class TableResultsRollbacker
  def initialize(table)
    @table = table
  end

  def call
    ActiveRecord::Base.transaction do
      rollback_rankings_earned_points
      restart_play_points
      remove_table_rankings
      set_table_as_opened
    end
  end

  private
  attr_reader :table

  def rollback_rankings_earned_points
    table.table_rankings.each do |table_ranking|
      ranking = table_ranking.user.ranking_on_tournament(table.tournament)
      ranking.points -= table_ranking.points
      ranking.save!
    end
  end

  def restart_play_points
    table.plays.update_all(points: nil)
  end

  def remove_table_rankings
    table.table_rankings.each { |winner| winner.destroy }
  end

  def set_table_as_opened
    table.update_attributes(opened: true)
  end
end
