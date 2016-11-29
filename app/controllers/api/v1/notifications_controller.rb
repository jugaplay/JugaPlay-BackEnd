class Api::V1::NotificationsController < Api::BaseController
  def index
    @notifications = current_user.notifications.limit(params[:to]).offset(params[:from]).order('created_at DESC')
  end

  def update
    @notification = Notification.find(params[:id])
    return render :show if @notification.update(update_notification_params)
    render_json_errors @notification.errors
  end

  private

  def update_notification_params
    params.permit(:read)
  end
end
