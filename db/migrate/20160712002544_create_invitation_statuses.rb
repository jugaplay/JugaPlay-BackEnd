class CreateInvitationStatuses < ActiveRecord::Migration
  def change
    create_table :invitation_statuses do |t|
      t.string :name

      t.timestamps null: false
    end
    
    add_index :invitation_statuses, :name, unique: true
     
     
  end
end
