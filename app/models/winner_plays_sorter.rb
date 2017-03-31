class WinnerPlaysSorter

  def initialize(table)
    @table = table
  end

  def call
    table_plays_by_points.each do |points, plays|
      sort_by_player(points, plays)
    end
    table_plays_by_points.values.flat_map(&:itself)
  end

  private
  attr_reader :table

  def sort_by_player(points, plays)
    if plays.many?
      points_matrix = build_play_with_players_points_matrix(plays)
      sorted_plays = []
      sort_plays(points_matrix, sorted_plays)
      table_plays_by_points[points] = sorted_plays
    else
      table_plays_by_points[points] = [plays]
    end
  end

  def build_play_with_players_points_matrix(plays)
    max_amount_of_players = plays.map(&:player_selections).map(&:count).max
    plays.map do |play|
      points_per_player = max_amount_of_players.times.map do |i|
        player_selection = play.player_selections[i]
        player_selection.nil? ? 0 : player_selection.points
      end
      { play: play, points_per_player: points_per_player }
    end
  end

  def sort_plays(points_matrix, result)
    if points_matrix.many?
      max_amount_of_players = points_matrix.first[:points_per_player].size
      max_amount_of_players.times.each do |i|
        points_to_compare = points_matrix.map { |data| data[:points_per_player][i] }
        indexes_with_max_value = points_to_compare.each_index.select { |index| points_to_compare[index].eql? points_to_compare.max }
        unless indexes_with_max_value.size.eql?(points_matrix.size)
          if indexes_with_max_value.many?
            sub_points_matrix = points_matrix.values_at(*indexes_with_max_value)
            sort_plays(sub_points_matrix, result)
          else
            index = indexes_with_max_value.first
            result << [points_matrix[index][:play]]
            points_matrix.delete_at(index)
            sort_plays(points_matrix, result)
            return
          end
        end
      end
    end
    result << points_matrix.map { |data| data[:play] }
  end

  def table_plays_by_points
    @table_plays_by_points ||= table.plays.order(points: :desc).group_by(&:points)
  end
end
