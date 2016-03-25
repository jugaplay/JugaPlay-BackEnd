class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.string :title, null: false
      t.integer :local_team_id, null: false
      t.integer :visitor_team_id, null: false
      t.datetime :datetime, null: false

      t.timestamps
    end

    add_index :matches, [:local_team_id, :visitor_team_id, :datetime], unique: true
  end
end
