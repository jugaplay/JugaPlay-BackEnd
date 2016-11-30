class Api::V1::TelephoneUpdateRequestsController < Api::BaseController
  TELEPHONE_ALREADY_TAKEN = 'El numero de telefono ya pertenece a otro usuario'
  MISSING_UPDATE_REQUEST = 'No se encontró una solicitud de cambio de numero de telefono con los datos ingresados'

  def validate
    return render_json_error MISSING_UPDATE_REQUEST unless update_request.present?
    return render_json_error TELEPHONE_ALREADY_TAKEN if telephone_already_taken?
    update_request.apply!
    user.reload
    render 'api/v1/users/show'
  end

  private

  def telephone_already_taken?
    User.where(telephone: update_request.telephone).exists?
  end

  def update_request
    @update_request ||= TelephoneUpdateRequest.where(user: user, validation_code: params[:validation_code], applied: false).first
  end

  def user
    @user ||= current_user
  end
end
