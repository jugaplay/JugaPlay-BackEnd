class MovePrizesToTableRankings < ActiveRecord::Migration
  def up
    add_column :table_rankings, :earned_coins, :integer, null: true

    prizes_data = ActiveRecord::Base.connection.execute('
      SELECT plays.id AS play_id, coins AS earned_coins, prizes.updated_at AS updated_at,
             prizes.created_at AS created_at, table_rankings.id AS table_ranking_id
      FROM prizes
        INNER JOIN plays ON (prizes.table_id = plays.table_id AND prizes.user_id = plays.user_id)
        INNER JOIN table_rankings ON (table_rankings.play_id = plays.id)
    ')
    puts "Preparing #{prizes_data.count} prizes to be moved to table rankings"

    table_rankigns_ids, table_rankigns_data = [], []
    prizes_data.each do |prize_data|
      table_rankigns_ids << prize_data['table_ranking_id']
      table_rankigns_data << {
        earned_coins: (prize_data['earned_coins'] || 0),
        created_at: prize_data['created_at'],
        updated_at: prize_data['updated_at'],
      }
    end

    puts "Moving #{table_rankigns_data.count} prizes to table rankings"
    TableRanking.update(table_rankigns_ids, table_rankigns_data)

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
