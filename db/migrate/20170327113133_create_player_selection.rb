class CreatePlayerSelection < ActiveRecord::Migration
  def up
    create_table :player_selections do |t|
      t.references :play, null: false, index: true
      t.references :player, null: false, index: true
      t.integer :position, null: false
      t.float :points, null: false
      t.timestamps
    end

    add_index :player_selections, [:play_id, :position], unique: true
    add_index :player_selections, [:play_id, :player_id], unique: true

    calculator = PlayerPointsCalculator.new
    tables = Table.all.to_a

    batch_size = 100
    total = Play.count
    batches = total/batch_size
    Play.find_in_batches(batch_size: batch_size).with_index do |plays, batch|
      puts "Importing player selections for #{batch_size} plays [#{batch}/#{batches}]"
      plays.each do |play|
        player_selections = []
        table = tables.detect { |table| table.id.eql? play.table_id }
        players_data = ActiveRecord::Base.connection.execute("SELECT players_plays.player_id AS player_id FROM players_plays WHERE players_plays.play_id = #{play.id}")
        players_ids = players_data.map { |data| data['player_id'] }

        Player.find(players_ids).each_with_index do |player, index|

          player_points = begin
            calculator.call(table, player)
          rescue MissingPlayerStats
            0
          end
          player_selections << PlayerSelection.new(player_id: player.id, play_id: play.id, points: player_points, position: index + 1)
        end

        # puts "Importing #{player_selections.count} player selections for play #{play.id}"
        PlayerSelection.import(player_selections)
      end
    end

    drop_table :players_plays
  end

  def down
    rename_table :player_selections, :players_plays
    remove_column :players_plays, :position
    remove_column :players_plays, :points
  end
end
