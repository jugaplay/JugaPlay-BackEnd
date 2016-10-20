class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :groups_users do |t|
      t.references :group, null: false, index: true
      t.references :user, null: false, index: true
      t.timestamps
      t.index [:group_id, :user_id], unique: true
    end
  end
end
