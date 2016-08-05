class Api::V1::RequestsController < Api::BaseController
  skip_before_filter :authenticate_user!, only: [:create]

  def index
    @requests = Request.where(host_user_id: params[:user_id])
  end
  
  def show
	 @request = Request.find(params[:id])
  end
  
  def create
  	
  		begin
		 	@user = User.find(params[:user_id])
	 	rescue ActiveRecord::RecordNotFound => e
    		return render_json_errors "user_id not found"
    	end
    	
    	begin
		 	@request_type = RequestType.where(name: params[:request_type_name]).first()
	 	rescue ActiveRecord::RecordNotFound => e
    		return render_json_errors "request_type_name not found"
    	end
    		
	    @request = Request.create(request_type: @request_type, host_user: @user)
	    
	    return render_json_errors @request.errors unless @request.save
	    render :show
	    
    
  end

  
end
