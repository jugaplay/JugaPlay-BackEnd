class CreateTEntryFees < ActiveRecord::Migration
  def change
    create_table :t_entry_fees do |t|
      t.integer :coins
      t.references :user, index: true, foreign_key: true
      t.string :detail
      t.references :tournament, index: true, foreign_key: true
      t.references :table, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
