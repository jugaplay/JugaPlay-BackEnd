class Api::BaseController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :authenticate_user!
  before_filter :ensure_json_request
  respond_to :json

  protected

  def ensure_json_request
    return if request.format == :json
    render nothing: true, status: 406
  end

  def render_json_errors(error_messages)
    render json: { errors: error_messages }
  end
end
