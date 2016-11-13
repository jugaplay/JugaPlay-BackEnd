class Api::V1::Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = facebook_user_login.call
    if @user.persisted?
      sign_in @user
      redirect_to "http://#{ENV['DOMAIN_NAME']}/facebookok.html"
    else
      session['devise.facebook_data'] = request.env['omniauth.auth']
      render json: { errors: @user.errors }
    end
  end

  def failure
    redirect_to "http://#{ENV['DOMAIN_NAME']}/facebookcancel.html"
  end

  private

  def facebook_user_login
    FacebookUserLogin.new request.env['omniauth.auth'], request.env['omniauth.params']
  end
end
