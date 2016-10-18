class RefactorTablePrizes < ActiveRecord::Migration
  def change
    rename_table :t_prizes, :user_prizes
    remove_column :user_prizes, :detail

    add_column :tables, :coins_for_winners, :text, default: []
    add_reference :user_prizes, :table


    puts 'Updating coins for winners for '
    batch = 0
    Table.find_in_batches(start: 20, batch_size: 20) do |tables|
      table_ids = []
      table_data = []
      queries = ''
      batch += 20
      tables.each do |table|
        # pick prizes data manually since there is no longer a model for them
        prizes_data = ActiveRecord::Base.connection.execute("SELECT id, coins FROM prizes WHERE table_id=#{table.id} ORDER BY position")
        coins_for_winners = prizes_data.map { |d| d['coins'].to_i }
        table_ids << table.id
        table_data << { coins_for_winners: coins_for_winners }
        unless coins_for_winners.empty?
          where_clause = prizes_data.map { |d| "prize_id = #{d['id'].to_i}" }.join(' OR ')
          queries += "UPDATE user_prizes SET table_id = #{table.id} WHERE #{where_clause}; "
        end
      end
      puts "Updating coins for winners: ##{batch}"
      Table.update(table_ids, table_data)
      puts "Updating the user prizes: ##{batch}"
      ActiveRecord::Base.connection.execute(queries)
    end

    change_column :user_prizes, :table_id, :integer, null: false
    change_column :user_prizes, :user_id, :integer, null: false
    change_column :user_prizes, :coins, :integer, null: false
    remove_reference :user_prizes, :prize
    drop_table :prizes
  end
end
