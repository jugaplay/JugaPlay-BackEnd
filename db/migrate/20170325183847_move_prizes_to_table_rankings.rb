class MovePrizesToTableRankings < ActiveRecord::Migration
  def up
    add_column :table_rankings, :earned_coins, :integer, null: true

    prizes_data = ActiveRecord::Base.connection.execute('SELECT table_id, user_id, coins, updated_at, created_at FROM prizes')
    prizes_data.each do |prize_data|
      coins = prize_data['coins']
      user_id = prize_data['user_id']
      table_id = prize_data['table_id']
      updated_at = prize_data['updated_at']
      created_at = prize_data['created_at']

      play = Play.find_by(user_id: user_id, table_id: table_id)
      unless play
        play = Play.create!(user_id: user_id, table_id: table_id)
      end

      table_ranking = play.table_ranking
      unless table_ranking
        last_position = Table.find(table_id).table_rankings.pluck(:position).max
        table_ranking = TableRanking.create!(play: play, position: last_position, earned_coins: coins, points: 0)
      end

      table_ranking.update_attributes!(earned_coins: coins, created_at: created_at, updated_at: updated_at)
    end

    change_column :table_rankings, :earned_coins, :integer, null: false
    drop_table :prizes
  end

  def down
    create_table :prizes do |t|
      t.integer :coins
      t.integer :position
      t.references :table
      t.timestamps null: false
    end

    prizes = []
    TableRanking.find_each do |table_ranking|
      prizes << Prize.new(table: table_ranking.table.id, user: table_ranking.user.id, coins: table_ranking.earned_coins)
    end
    Prize.import(prizes)

    remove_column :table_rankings, :earned_coins
  end
end
