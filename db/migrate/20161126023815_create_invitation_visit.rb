class CreateInvitationVisit < ActiveRecord::Migration
  def change
    create_table :invitation_visits do |t|
      t.references :invitation_request, null: false
      t.inet :ip, null: false

      t.timestamps
    end
  end
end
