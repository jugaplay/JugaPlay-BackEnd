json.notifications_setting do
  json.partial! partial: 'api/v1/notifications_settings/notifications_setting', locals: { notifications_setting: @notifications_setting }
end
