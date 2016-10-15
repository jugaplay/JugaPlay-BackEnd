class RemoveLanguages < ActiveRecord::Migration
  def up
    remove_reference :countries, :language
    drop_table :languages
  end

  def down
    create_table :languages do |t|
      t.string :name
      t.timestamps null: false
      t.index :name, unique: true
    end
    add_reference :countries, :language_id
  end
end
