class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :position, null: false
      t.text :description, null: false, default: ''
      t.date :birthday, null: false
      t.string :nationality, null: false
      t.float :weight, null: false
      t.float :height, null: false
      t.references :team
    end

    add_index :players, :first_name
    add_index :players, :last_name
    add_index :players, [:first_name, :last_name, :team_id, :position], unique: true, name: 'index_players_first_last_team_position'
  end
end
