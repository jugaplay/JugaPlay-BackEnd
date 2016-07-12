ActiveRecord::Base.transaction do
 
 ## REQUEST TYPES
 ## Request_Type: Facebook - Whatsapp - SMS - Mail

 RequestType.create!(name:'Facebook')
 RequestType.create!(name:'Whatsapp')
 RequestType.create!(name:'SMS')
 RequestType.create!(name:'Mail')


 ## REQUEST STATUS
 ## Request_Status: Unused - Entered- Registered 
 
 RequestStatus.create!(name:'Unused')
 RequestStatus.create!(name:'Entered')
 RequestStatus.create!(name:'Registered')
  
 
 
 
end