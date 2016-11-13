class FacebookUserLogin
  def initialize(omniauth_params, query_params)
    @omniauth_params = omniauth_params
    @query_params = query_params
  end
  
  def call
    return update_existing_user if user_email_already_exists?
    create_new_user
    dispense_coins if new_user_was_invited?
    new_user
  end

  private
  attr_accessor :omniauth_params, :query_params, :new_user

  def update_existing_user
    existing_user.update_attributes(
      provider: 'facebook',
      email: omniauth_params.info.email,
      image: omniauth_params.info.image,
      facebook_id: omniauth_params.uid,
      facebook_token: omniauth_params.credentials.token)
    existing_user
  end

  def create_new_user
    @new_user = User.where(provider: omniauth_params.provider, facebook_id: omniauth_params.uid).first_or_create do |user|
      user.facebook_token = omniauth_params.credentials.token
      user.first_name = omniauth_params.info.first_name
      user.last_name = omniauth_params.info.last_name
      user.email = omniauth_params.info.email
      user.nickname = build_nickname
      user.password = Devise.friendly_token[0, 20]
      user.image = omniauth_params.info.image
      user.wallet = Wallet.new
      user.address_book = AddressBook.new
    end
  end

  def dispense_coins
    new_user.update_attributes(invited_by: inviting_user)
    inviting_user.win_coins!(10)
  end

  def new_user_was_invited?
    inviting_user.present?
  end

  def user_email_already_exists?
    existing_user.present?
  end

  def existing_user
    @existing_user ||= User.find_by(email: omniauth_params.info.email)
  end

  def inviting_user
    @inviting_user ||= User.find_by_id(query_params['invited_by'])
  end

  def build_nickname
    return omniauth_params.uid unless omniauth_params.info.email.present?
    omniauth_params.info.email.split('@').first + Random.rand(999).to_s
  end
end
