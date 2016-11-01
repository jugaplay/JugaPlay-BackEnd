class Admin::BaseController < ApplicationController
  protect_from_forgery with: :exception
  before_filter :authenticate_admin_user!

  protected

  def authenticate_admin_user!
    return redirect_to admin_login_path unless user_signed_in?
    redirect_to admin_logout_path unless current_user.admin?
  end

  def redirect_with_success_message path, message
    redirect_to path, flash: { success: message }
  end

  def redirect_with_error_message path, error, message = ''
    redirect_to path, flash: { error: "#{error.message}\n#{message}" }
  end

  def redirect_with_error_messages path, error_messages
    redirect_to path, flash: { error: error_messages.join("\n") }
  end

  def render_with_error_message template, error
    flash.now[:error] = error.message
    render template
  end
end
