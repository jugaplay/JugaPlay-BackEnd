class RenameChannelToNotificationsSetting < ActiveRecord::Migration
  def change
    rename_table :channels, :notifications_settings
    change_column :notifications_settings, :sms, :boolean, null: false, default: false
    change_column :notifications_settings, :push, :boolean, null: false, default: false
    change_column :notifications_settings, :whatsapp, :boolean, null: false, default: false
    add_column :notifications_settings, :facebook, :boolean, null: false, default: false

    settings = []
    NotificationsSetting.delete_all
    User.find_each { |user| settings << NotificationsSetting.new(user: user) }
    NotificationsSetting.import(settings)
  end
end
