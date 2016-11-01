namespace :facebook do
  task reset_tokens: :environment do
    User.where.not(facebook_id: nil).each do |user|
      user.update_attributes!(facebook_token: nil)
    end
  end
end
