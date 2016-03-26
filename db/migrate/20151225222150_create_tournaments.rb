class CreateTournaments < ActiveRecord::Migration
  def change
    create_table :tournaments do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :tournaments, :name, unique: true

    add_column :tables, :tournament_id, :integer, null: false
  end
end
