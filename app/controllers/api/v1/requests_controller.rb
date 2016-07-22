class Api::V1::RequestsController < Api::BaseController
  skip_before_filter :authenticate_user!, only: [:create]

  def index
    @requests = Request.where(host_user_id: params[:user_id])
  end
  
  def show
	 @request = Request.find(params[:id])
  end
  
  def create
 	@user = User.find(params[:user_id])
 	@request_type = RequestType.find(params[:request_type_id])
    @request = Request.create(request_type: @request_type, host_user: @user)
    render :show
  end

  
end
