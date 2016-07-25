class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user, index: true, foreign_key: true
      t.references :notification_type, index: true, foreign_key: true
      t.string :title
      t.string :imagen
      t.text :nvarchar
      t.text :action

      t.timestamps null: false
    end
  end
end
