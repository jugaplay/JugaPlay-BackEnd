class Api::V1::UsersController < Api::BaseController
  skip_before_filter :authenticate_user!, only: [:create]

  def create
    @user = User.new(create_user_params)  
    return render_json_errors @user.errors unless @user.save
    @user.invited_by.win_coins!(Wallet::COINS_PER_INVITATION) if @user.invited_by.present?
    WelcomeMailer.send_welcome_message(@user).deliver_now
    render :show
  end

  def update
    @user = current_user
    return render :show if @user.update(update_user_params)
    render_json_errors @user.errors
  end

  def show
    @user = current_user
  end

  private

  def create_user_params
    if params[:user].present?
      build_base_nickname if params[:user][:email].present? && params[:user][:nickname].nil?
      params[:user][:provider] = 'facebook' if params[:user][:uid].present?
    end
    user_params = params.require(:user).permit(:first_name, :last_name, :email, :nickname, :password, :password_confirmation, :invited_by_id, :uid, :image, :provider)
    user_params[:wallet] = Wallet.new
    user_params[:channel] = Channel.new
    user_params
  end

  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :nickname, :password, :telephone, :push_token)
  end

  def build_base_nickname
    # TODO: Remove this when front-end implements new form
    nickname = params[:user][:email].partition('@').first
    count = User.where("email LIKE '#{nickname}@%'").count
    nickname = "#{nickname}_#{count}" if count > 0
    params[:user][:nickname] = nickname
  end
end
