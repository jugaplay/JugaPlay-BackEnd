class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :sender_name
      t.string :sender_email
      t.text :content, null: false

      t.timestamps
    end
  end
end
