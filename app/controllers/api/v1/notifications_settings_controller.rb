class Api::V1::NotificationsSettingsController < Api::BaseController
  def show
    notifications_setting
  end

  def update
    return render :show if notifications_setting.update(notifications_setting_params)
    render_json_errors notifications_setting.errors
  end

  private

  def notifications_setting
    @notifications_setting ||= current_user.notifications_setting
  end

  def notifications_setting_params
    params.require(:notifications_setting).permit(:sms, :mail, :push, :whatsapp, :facebook)
  end
end
