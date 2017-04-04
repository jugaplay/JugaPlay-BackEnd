class RenameTableWinnersToTableRankings < ActiveRecord::Migration
  def up
    rename_table :table_winners, :table_rankings

    puts 'Adding play and points to table rankings'
    add_reference :table_rankings, :play
    add_column :table_rankings, :points, :float, null: false, default: 0

    puts 'Cleanning rankings without plays'
    rankings_without_plays = ActiveRecord::Base.connection.execute('
      SELECT table_rankings.id AS ranking_id
      FROM table_rankings LEFT JOIN plays ON (table_rankings.table_id = plays.table_id AND table_rankings.user_id = plays.user_id)
      WHERE plays.id IS NULL
    ')
    rankings_without_play_ids = rankings_without_plays.map { |ranking_data| ranking_data['ranking_id'] }
    puts "Deleting #{rankings_without_play_ids.count} table rankings without plays [#{rankings_without_play_ids.join(', ')}]"
    TableRanking.delete(rankings_without_play_ids)

    puts 'Calculating plays for each table ranking'
    table_rankings_data = ActiveRecord::Base.connection.execute('
      SELECT table_rankings.id AS ranking_id, table_rankings.created_at AS created_at,
             plays.id AS play_id, table_rankings.updated_at AS updated_at
      FROM table_rankings INNER JOIN plays ON table_rankings.table_id = plays.table_id
      WHERE table_rankings.user_id = plays.user_id
    ')
    rankings_data = table_rankings_data.map do |table_ranking_data|
      {
        id: table_ranking_data['ranking_id'],
        play_id: table_ranking_data['play_id'],
        updated_at: table_ranking_data['updated_at'],
        created_at: table_ranking_data['created_at'],
      }
    end

    puts 'Calculating points for each table ranking'
    Table.find_each do |table|
      points_for_winners = table.points_for_winners
      table.table_rankings.limit(points_for_winners.count).each do |table_ranking|
        ranking_data = rankings_data.detect { |ranking_data| ranking_data[:id].eql? table_ranking.id }
        ranking_data[:points] = points_for_winners[table_ranking.position - 1] unless ranking_data.nil?
      end
    end

    puts 'Updating table rankings'
    TableRanking.transaction do
      queries = rankings_data.map do |ranking_data|
        "UPDATE table_rankings SET
          play_id = #{ranking_data[:play_id]}, updated_at = '#{ranking_data[:updated_at]}',
          points = #{ranking_data[:points] || 0}, created_at = '#{ranking_data[:updated_at]}'
          WHERE id = #{ranking_data[:id]}"
      end
      puts "Updating: #{queries.count} rankings"
      TableRanking.connection.execute(queries.join('; '))
    end

    remove_reference :table_rankings, :user
    remove_reference :table_rankings, :table
  end

  def down
    add_reference :table_rankings, :user
    add_reference :table_rankings, :table

    table_rankings_data = ActiveRecord::Base.connection.execute('
      SELECT table_rankings.id AS ranking_id, plays.user_id AS user_id, plays.table_id
      FROM table_rankings INNER JOIN plays ON table_rankings.play_id = plays.id
    ')
    ranking_ids = table_rankings_data.map { |table_ranking_data| table_ranking_data['ranking_id'] }
    data_for_update = table_rankings_data.map { |table_ranking_data| { user_id: table_ranking_data['user_id'], table_id: table_ranking_data['table_id'] } }
    TableRanking.update(ranking_ids, data_for_update)

    remove_reference :table_rankings, :play
    remove_column :table_rankings, :points
    rename_table :table_rankings, :table_winners
  end
end
