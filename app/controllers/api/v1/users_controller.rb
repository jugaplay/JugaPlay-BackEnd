class Api::V1::UsersController < Api::BaseController
  skip_before_filter :authenticate_user!, only: [:create]

  def show
    user
  end

  def create
    @user = User.new(create_user_params)
    return render_json_errors user.errors unless user.save
    TPromotion.registration!(@user)
    WelcomeMailer.send_welcome_message(@user).deliver_now
    render :show
  end

  def update
    return render_json_errors user.errors unless user.update(update_user_params)
    send_telephone_update_request_if_necessary
    render :show
  end

  def search
    users = UsersSearchEngine.new
    users.with_name_nickname_or_email_including(search_params[:q]) if search_params[:q].present?
    users.playing_tournament(search_params[:playing_tournament]) if search_params[:playing_tournament].present?
    users.sorted_by_ranking if search_params[:order_by_ranking].present?
    users.sorted_by_name if search_params[:order_by_name].present?
    @total_items = users.map(&:id).size
    @users = users.page(params[:page])
    render :index
  end

  private

  def send_telephone_update_request_if_necessary
    phone = params[:user][:telephone]
    return if phone.nil?
    TelephoneUpdateRequester.new(user, phone).call
  end

  def create_user_params
    user_params = params.require(:user).permit(:first_name, :last_name, :email, :nickname, :password, :password_confirmation)
    user_params[:wallet] = Wallet.new
    user_params[:channel] = Channel.new
    user_params[:address_book] = AddressBook.new
    user_params[:nickname] = build_base_nickname if params[:user][:nickname].nil?
    user_params
  end

  def build_base_nickname
    nickname = params[:user][:email].partition('@').first
    count = User.where("email LIKE '#{nickname}@%'").count
    nickname = "#{nickname}#{count}" if count > 0
    nickname
  end

  def search_params
    params.require(:search).permit(:q, :playing_tournament, :order_by_ranking, :order_by_name)
  end

  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :nickname, :password, :push_token)
  end

  def user
    @user ||= current_user
  end
end
