class CreateExplanationsUsers < ActiveRecord::Migration
  def change
    create_table :explanations_users do |t|
      t.references :user, null: false
      t.references :explanation, null: false

      t.timestamps null: false
    end
  end
end
