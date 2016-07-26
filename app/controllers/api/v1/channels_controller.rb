class Api::V1::ChannelsController < Api::BaseController

  def index
  	@channel = Channel.find_by_user_id(params[:user_id])
  end

  def update
  end
end
