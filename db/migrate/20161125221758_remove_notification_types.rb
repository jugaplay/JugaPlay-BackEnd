class RemoveNotificationTypes < ActiveRecord::Migration
  def up
    types_data = ActiveRecord::Base.connection.execute('SELECT * from notification_types')

    add_column :notifications, :type, :string
    Notification.find_each do |notification|
      type_data_for_notification = types_data.detect { |type_data| type_data['id'].to_i.eql? notification.notification_type_id }
      notification.update_attributes(type: type_data_for_notification['name'])
    end
    change_column :notifications, :type, :string, null: false

    remove_column :notifications, :notification_type_id
    drop_table :notification_types
  end

  def down
    create_table :notification_types do |t|
      t.string :name
      t.timestamps null: false
      t.index :name, unique: true
    end
    NotificationType::ALL.each { |type_name| NotificationType.create!(name: type_name) }

    add_reference :notifications, :notification_type
    Notification.find_each do |notification|
      type_id = NotificationType.find_by_name(notification.type).id
      notification.update_attributes(notification_type_id: type_id)
    end

    remove_column :notifications, :type
  end
end
