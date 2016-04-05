class Api::V1::Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
 
  def facebook
    @user = User.from_omniauth(request.env['omniauth.auth'])
    if @user.persisted?
      sign_in @user
      redirect_to "http://#{ENV['DOMAIN_NAME']}"
    else
      session['devise.facebook_data'] = request.env['omniauth.auth']
      @host_user = User.find(params[:invited_by])
      @host_user.win_coins!(10)
      render json: { errors: @user.errors }
    end
  end

  def failure
    render json: { errors: 'There was an error trying to login with facebook' }
  end
end