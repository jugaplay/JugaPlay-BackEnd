class Api::BaseController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :ensure_json_request
  before_filter :authenticate_user!

  respond_to :json

  protected

  def ensure_json_request
    return if request.format == :json
    render nothing: true, status: 406
  end

  def authenticate_user!
    return render_unauthorized_user unless user_signed_in?
    facebook_token_manager.call do |user|
      sign_out user
      return redirect_to_home_page
    end
  end

  # TODO: Tendríamos que usar tokens en vez de cookies
  # def authenticate_user!
  #   return render_unauthorized_user unless user_signed_in?
  #   set_headers
  # end
  #
  # def set_headers
  #   response.headers['Authorization'] = current_user.auth_token
  # end
  #
  # def user_signed_in?
  #   current_user.present?
  # end
  #
  # def current_user
  #   @current_user ||= User.find_by(auth_token: request.headers['Authorization'])
  # end

  def render_unauthorized_user
    render_json_error 'You need to sign in or sign up before continuing.', 401
  end

  # def render_json_rails_errors(rails_errors, status = 400)
  #   render_json_errors rails_errors.full_messages, status
  # end

  def render_json_error(error_message, status = 400)
    render_json_errors [error_message], status
  end

  # TODO: Tendríamos que mandar errores con 400
  def render_json_errors(error_messages, status = 200)
    render json: { errors: error_messages }, status: status
  end

  def redirect_to_home_page
    redirect_to "http://#{ENV['DOMAIN_NAME']}"
  end

  def facebook_requester
    FacebookRequester.new current_user
  end

  def facebook_token_manager
    FacebookTokenManager.new current_user
  end
end
