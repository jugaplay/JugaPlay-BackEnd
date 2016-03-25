class AddNicknameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :nickname, :string

    nick_names = {}
    User.all.pluck(:email).map { |e| e.partition('@').first }.each { |nick_name| nick_names[nick_name] = 0 }
    User.all.each do |user|
      nick_name = user.email.partition('@').first
      count = nick_names[nick_name]

      nick_name = "#{nick_name}_#{count}" if count > 0
      user.update_attributes(nickname: nick_name)
      nick_names[nick_name] = count + 1
    end

    change_column :users, :nickname, :string, null: false
    add_index :users, :nickname, unique: true
  end
end
