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
    Table.find_each do |table|
      puts "Calculating plays points for table #{table.id}"
      player_selections = []
      table.play_ids.each do |play_id|
        players_data = ActiveRecord::Base.connection.execute("SELECT players_plays.player_id AS player_id FROM players_plays WHERE players_plays.play_id = #{play_id}")
        puts "Calculating points for #{players_data.count} players of play #{play_id}"
        players_data.each_with_index do |data, index|
          player_id = data['player_id']
          player = Player.find(player_id)
          player_points = calculator.call(table, player)
          player_selections << PlayerSelection.new(player_id: player_id, play_id: play_id, points: player_points, position: index + 1)
        end
      end
      puts "Importing #{player_selections.count} player selections for table #{table.id}"
      PlayerSelection.import(player_selections)
    end

    drop_table :players_plays
  end

  def down
    rename_table :player_selections, :players_plays
    remove_column :players_plays, :position
    remove_column :players_plays, :points
  end
end
