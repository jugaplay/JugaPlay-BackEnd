class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.boolean :mail
      t.boolean :sms
      t.boolean :whatsapp
      t.boolean :push

      t.timestamps null: false
    end
  end
end
