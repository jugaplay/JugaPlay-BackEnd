class MovePrizesToTableRankings < ActiveRecord::Migration
  def up
    add_column :table_rankings, :earned_coins, :integer, null: true

    prizes_data = ActiveRecord::Base.connection.execute('SELECT table_id, user_id, coins, updated_at, created_at FROM prizes')
    puts "Moving #{prizes_data.count} prizes to table rankings"
    prizes_data.each do |prize_data|
      coins = prize_data['coins']
      user_id = prize_data['user_id']
      table_id = prize_data['table_id']
      updated_at = prize_data['updated_at']
      created_at = prize_data['created_at']

      play = Play.find_by(user_id: user_id, table_id: table_id)
      fail "Missing play for user #{user_id} and table #{table_id}" unless play

      table_ranking = play.table_ranking
      fail "Missing table ranking for play #{play.id}" unless play unless table_ranking

      table_ranking.update_attributes!(earned_coins: coins, created_at: created_at, updated_at: updated_at)
    end

    table_rankings_with_null_earned_coins = ActiveRecord::Base.connection.execute('SELECT id FROM table_rankings WHERE earned_coins IS NULL')
    puts "#{table_rankings_with_null_earned_coins.count} table rankings where found with null earned coins, setting to 0"
    updating_data = table_rankings_with_null_earned_coins.map { |_| { earned_coins: 0 } }
    rankings_with_null_earned_coins_ids = table_rankings_with_null_earned_coins.map { |data| data['id']  }
    TableRanking.update(rankings_with_null_earned_coins_ids, updating_data)

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
