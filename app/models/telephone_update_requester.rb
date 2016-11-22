require 'rest-client'

class TelephoneUpdateRequester
  def initialize(user, telephone)
    @user = user
    @telephone = telephone
  end

  def call
    TelephoneUpdateRequest.create!(user: user, telephone: telephone, validation_code: validation_code)
    send_validation_code
  end

  private
  attr_reader :user, :telephone

  def send_validation_code
    sms_server = RestClient::Resource.new(ENV['BLOWERIO_URL'])
    sms_server['/messages'].post(to: "+#{telephone}", message: validation_code)
  end

  def validation_code
    @validation_code ||= rand.to_s[2..7]
  end
end
