class Api::V1::Users::UnlocksController < Devise::UnlocksController
  # GET /resource/unlock/new
  # def new
  #   super
  # end

  # POST /resource/unlock
  def create
    self.resource = resource_class.send_unlock_instructions(resource_params)
    yield resource if block_given?
    return render json: { success: true } if successfully_sent?(resource)
    render json: { errors: resource.errors }, status: 406
  end

  #?unlock_token=78348f87775d6487a438fc00f491b79a0c3d0e01e24d0df68b880bc19b57abf6

  # GET /resource/unlock?unlock_token=abcdef
  def show
    self.resource = resource_class.unlock_access_by_token(params[:unlock_token])
    yield resource if block_given?
    return render json: { success: true } if resource.errors.empty?
    render json: { errors: resource.errors }, status: :unprocessable_entity
  end

  # protected

  # The path used after sending unlock password instructions
  # def after_sending_unlock_instructions_path_for(resource)
  #   super(resource)
  # end

  # The path used after unlocking the resource
  # def after_unlock_path_for(resource)
  #   super(resource)
  # end
end
