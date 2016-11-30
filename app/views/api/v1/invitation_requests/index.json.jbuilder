json.invitation_requests do
  json.partial! partial: 'api/v1/invitation_requests/invitation_request', collection: @invitation_requests, as: :invitation_request
end
