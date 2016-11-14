class Api::V1::UsersController < Api::BaseController
  skip_before_filter :authenticate_user!, only: [:create]

  def show
    user
  end

  def create
    @user = User.new(create_user_params)
    return render_json_errors user.errors unless user.save
    if user.invited_by.present?
      user.invited_by.win_coins!(Wallet::COINS_PER_INVITATION)
      @invitation = Invitation.where(id: params[:user][:invitation_id]).first() if params[:user][:invitation_id].present?
      @invitation.update(won_coins: Wallet::COINS_PER_INVITATION, guest_user_id: user.id, guest_ip: request.remote_ip, invitation_status: InvitationStatus.find_by_name('Registered')) if @invitation.present?
      TPromotion.create!(coins: Wallet::COINS_PER_INVITATION, user: user.invited_by, detail: 'Invitación a ' + user.nickname, promotion_type: 'friend-invitation')
    end
    TPromotion.create!(coins: Wallet::COINS_PER_REGISTRATION, user: @user, detail: 'Bienvenida a JugaPlay', promotion_type: 'registration')
    WelcomeMailer.send_welcome_message(@user).deliver_now
    render :show
  end

  def update
    return render :show if user.update(update_user_params)
    render_json_errors user.errors
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

  def create_user_params
    user_params = params.require(:user).permit(:first_name, :last_name, :email, :nickname, :password, :password_confirmation, :invited_by_id)
    user_params[:wallet] = Wallet.new
    user_params[:channel] = Channel.new
    user_params[:address_book] = AddressBook.new
    user_params[:nickname] = build_base_nickname if params[:user][:nickname].nil?
    user_params
  end

  def build_base_nickname
    # TODO: Remove this when front-end implements new form
    nickname = params[:user][:email].partition('@').first
    count = User.where("email LIKE '#{nickname}@%'").count
    nickname = "#{nickname}#{count}" if count > 0
    nickname
  end

  def search_params
    params.require(:search).permit(:q, :playing_tournament, :order_by_ranking, :order_by_name)
  end

  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :nickname, :password, :telephone, :push_token)
  end

  def user
    @user ||= current_user
  end
end
