class Api::V1::NotificationsController < Api::BaseController
  skip_before_filter :authenticate_user!, only: [:create]

  def index
    @notifications = Notification.where(user_id: params[:user_id]).limit(params[:to]).offset(params[:from])
  end


  def create

 	@user = User.find(params[:user_id])
 	@type = NotificationType.where(name: params[:type_name]).first
 	
    @notification = Notification.new(user: @user, notification_type: @type, title: params[:title],
    image: params[:image], text: params[:text], action: params[:action])
    
    return render_json_errors @notification.errors unless @notification.save
    
    @user.notifications<<(@notification)
    render :show

     
  end

    
end
