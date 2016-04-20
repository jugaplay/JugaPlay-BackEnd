class Api::V1::Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def facebook
  	
	 @user = User.from_omniauth(request.env['omniauth.auth'],request.env['omniauth.params'])
    	
	if @user.persisted?
      sign_in @user     
    else
      session['devise.facebook_data'] = request.env['omniauth.auth']
    end
    
     redirect_to "http://#{ENV['DOMAIN_NAME']}"
     
  end
  
  
 def failure
    render json: { errors: 'There was an error trying to login with facebook' }
  end
  
  
end