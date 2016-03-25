class CreateDataFactoryPlayersMapping < ActiveRecord::Migration
  def change
    create_table :data_factory_players_mappings do |t|
      t.references :player
      t.integer :data_factory_id

      t.timestamps
    end

    add_index :data_factory_players_mappings, [:player_id, :data_factory_id], unique: true, name: 'index_data_factory_players_mappings_player_df_id'
    add_index :data_factory_players_mappings, :player_id, unique: true
    add_index :data_factory_players_mappings, :data_factory_id, unique: true
  end
end
