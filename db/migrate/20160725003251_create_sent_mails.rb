
class CreateSentMails < ActiveRecord::Migration
  def change
    create_table :sent_mails do |t|
      t.string :from
      t.string :to
      t.string :subject

      t.timestamps

    end
  end
end
