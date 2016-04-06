class Api::V1::Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
 
  def facebook
	
	@params = request.env['omniauth.params']
	@auth = request.env['omniauth.auth']
	
    user_by_email = User.find_by_email( @auth.info.email)
    return user_by_email if user_by_email.present?
    User.where(provider: @auth.provider, uid: @auth.uid).first_or_create do |user|
      user.first_name = @auth.info.first_name
      user.last_name = @auth.info.last_name
      user.email = @auth.info.email
      user.nickname = @auth.uid
      user.password = Devise.friendly_token[0,20]
      user.image = @auth.info.image
      user.wallet = Wallet.new
    end
    
    @host_user = User.find( @params["invited_by"])
    @host_user.win_coins!(10)
    
    
   if user.persisted?
      sign_in user
      redirect_to "http://#{ENV['DOMAIN_NAME']}"
    else
      session['devise.facebook_data'] = request.env['omniauth.auth']
      render json: { errors: @user.errors }
    end
  end
  
  
  
  
  

  def failure
    render json: { errors: 'There was an error trying to login with facebook' }
  end
end