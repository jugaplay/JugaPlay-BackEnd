class Api::V1::AddressBooksController < Api::BaseController
  def show
    address_book
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e }, status: 422
  end

  def synch
    synchronizer.call_with_emails params[:emails]
    synchronizer.call_with_facebook_ids params[:facebook_ids]
    head :ok
  rescue ActiveRecord::RecordNotFound => error
    render_json_errors error.message
  end

  private

  def address_book
    @address_book ||= AddressBook.find_by_user_id(current_user.id)
  end

  def synchronizer
    @synchronizer ||= AddressBookSynchronizer.new(current_user)
  end
end
