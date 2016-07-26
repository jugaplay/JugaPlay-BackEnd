class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.references :user, null: false
      t.boolean :mail, null: false, default: true
      t.boolean :sms, null: false, default: true
      t.boolean :whatsapp, null: false, default: true
      t.boolean :push, null: false, default: true

      t.timestamps null: false
    end
  end
end
