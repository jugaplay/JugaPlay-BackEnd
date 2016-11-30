json.notifications do
  json.partial! partial: 'api/v1/notifications/notification', collection: @notifications, as: :notification
end
