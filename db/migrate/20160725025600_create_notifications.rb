class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user, index: true, foreign_key: true
      t.references :notification_type, index: true, foreign_key: true
      t.string :title, null: false
      t.string :image
      t.text :text
      t.text :action
      t.boolean :read, null:false, default:false

      t.timestamps null: false
    end
  end
end
