class WelcomeMailer < ActionMailer::Base
  INFO_MAIL = 'info@jugaplay.com'

  layout false

  def send_welcome_message(user)
    mail to: user.email, from: INFO_MAIL, subject: 'Bienvenido!' do |format|
      format.html { render 'mailer/welcome_mailer/send_welcome_message' }
    end
  end
end
