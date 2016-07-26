class Api::V1::ChannelsController < Api::BaseController

  def index
  	@channel = Channel.find_by_user_id(params[:user_id])
  end

  def update
  	@channel =  Channel.find_by_user_id(params[:user_id]) 
    return render :show if @channel.update(update_channel_params)
    render_json_errors @channel.errors
  end

private

  def update_channel_params
    params.require(:channel).permit(:sms, :whatsapp, :mail, :push)
  end


end
