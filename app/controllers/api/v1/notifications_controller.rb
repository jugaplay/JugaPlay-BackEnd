class Api::V1::NotificationsController < Api::BaseController
  skip_before_filter :authenticate_user!, only: [:create]

  def index
    @notifications = Notification.where(user_id: params[:user_id]).limit(params[:to]).offset(params[:from])
  end


  def update
   	@notification = Notification.find(params[:id])
    return render :show if @notification.update(update_notification_params)
    render_json_errors @notification.errors
  end

  
  def update_notification_params
    params.permit(:read)
  end

    
end
