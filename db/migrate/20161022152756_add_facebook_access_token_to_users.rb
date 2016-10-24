class AddFacebookAccessTokenToUsers < ActiveRecord::Migration
  def up
    add_column :users, :facebook_token, :string

    puts 'Updating user facebook access tokens'
    user_ids = []
    user_data = []

    User.find_each do |user|
      if user.facebook_id.present?
        user_ids << user.id
        user_data << { facebook_token: Devise.friendly_token[0, 255] }
      end
    end

    puts "Updating users: #{user_data}"
    User.update(user_ids, user_data)
  end

  def down
    remove_column :users, :facebook_token
  end
end
