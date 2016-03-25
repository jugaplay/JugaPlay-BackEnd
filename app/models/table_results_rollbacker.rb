class TableResultsRollbacker
  def initialize(table)
    @table = table
  end

  def call
    ActiveRecord::Base.transaction do
      rollback_rankings_earned_points
      restart_play_points
      remove_table_winners
      set_table_as_opened
    end
  end

  private
  attr_reader :table

  def rollback_rankings_earned_points
    table.winners.each do |winner|
      ranking = winner.user.ranking_on_tournament(table.tournament)
      ranking.points -= table.payed_points(winner.user) { fail "Missing points for user #{winner.user.id}" }
      ranking.save!
    end
  end

  def restart_play_points
    table.plays.update_all(points: nil)
  end

  def remove_table_winners
    table.winners.each { |winner| winner.destroy }
  end

  def set_table_as_opened
    table.update_attributes(opened: true)
  end
end
