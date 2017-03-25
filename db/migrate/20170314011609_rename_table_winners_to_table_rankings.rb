class RenameTableWinnersToTableRankings < ActiveRecord::Migration
  def up
    puts 'Adding play references to table rankings'
    rename_table :table_winners, :table_rankings
    add_reference :table_rankings, :play

    table_rankings_data = ActiveRecord::Base.connection.execute('
      SELECT table_rankings.id AS ranking_id, table_rankings.created_at AS created_at,
             plays.id AS play_id, table_rankings.updated_at AS updated_at
      FROM table_rankings INNER JOIN plays ON table_rankings.table_id = plays.table_id
      WHERE table_rankings.user_id = plays.user_id'
    )

    ranking_ids = table_rankings_data.map { |table_ranking_data| table_ranking_data['ranking_id'] }
    rankings_data = table_rankings_data.map do |table_ranking_data|
      {
        play_id: table_ranking_data['play_id'],
        update_at: table_ranking_data['updated_at'],
        created_at: table_ranking_data['created_at'],
      }
    end

    TableRanking.update(ranking_ids, rankings_data)

    change_column :table_rankings, :play_id, :integer, null: false
    add_index :table_rankings, :play_id, unique: true

    remove_reference :table_rankings, :user
    remove_reference :table_rankings, :table

    add_column :table_rankings, :points, :float, null: false, default: 0

    puts 'Calculating earned points for every ranking'
    ranking_ids, ranking_points = [], []
    Table.find_each do |table|
      points_for_winners = table.points_for_winners
      table.table_rankings.limit(points_for_winners.count).each do |table_ranking|
        ranking_ids << table_ranking.id
        ranking_points << { points: points_for_winners[table_ranking.position - 1] }
      end
    end

    puts 'Updating earned points to every table ranking'
    TableRanking.update(ranking_ids, ranking_points)
  end

  def down
    add_reference :table_rankings, :user
    add_reference :table_rankings, :table

    table_rankings_data = ActiveRecord::Base.connection.execute('SELECT table_rankings.id AS ranking_id, plays.user_id AS user_id, plays.table_id from table_rankings inner join plays ON table_rankings.play_id = plays.id')
    ranking_ids = table_rankings_data.map { |table_ranking_data| table_ranking_data['ranking_id'] }
    data_for_update = table_rankings_data.map { |table_ranking_data| { user_id: table_ranking_data['user_id'], table_id: table_ranking_data['table_id'] } }
    TableRanking.update(ranking_ids, data_for_update)

    remove_reference :table_rankings, :play
    remove_column :table_rankings, :points
    rename_table :table_rankings, :table_winners
  end
end
