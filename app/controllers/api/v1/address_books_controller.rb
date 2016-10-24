class Api::V1::AddressBooksController < Api::BaseController
  def show
    address_book
  rescue ActiveRecord::RecordNotFound => error
    render_json_error error.message
  end

  def synch
    synchronizer.call_with_emails emails
    synchronizer.call_with_facebook_ids(facebook_ids) if current_user.has_facebook_login?
    render :show
  rescue ActiveRecord::RecordNotFound => error
    render_json_error error.message
  end

  private

  def emails
    params[:emails] || []
  end

  def facebook_ids
    facebook_requester.friends_list.map(&:id)
  end

  def address_book
    @address_book ||= AddressBook.find_by_user_id(current_user.id)
  end

  def synchronizer
    @synchronizer ||= AddressBookSynchronizer.new(address_book)
  end
end
