class Admin::SessionsController < Devise::SessionsController
  def create
    return redirect_to admin_login_path unless params[:user][:email].eql? User::ADMIN_EMAIL
    super
  end

  def after_sign_in_path_for(resource)
    admin_root_path
  end

  def after_sign_out_path_for(resource)
    admin_login_path
  end
end
