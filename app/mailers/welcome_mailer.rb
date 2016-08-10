class WelcomeMailer < ActionMailer::Base
  INFO_MAIL = 'info@jugaplay.com'

  layout false

  def send_welcome_message(user)
    
    mail to: user.email, from: INFO_MAIL, subject: 'Bienvenido!' do |format|
      format.html { render 'mailer/welcome_mailer/send_welcome_message' }
    end
     
    if(user.invited_by.present?)
	    @notification_type = NotificationType.where(name: 'friend-invitation').first()
	   
	    @title = user.nickname + ' se ha unido a a JugaPlay gracias a tu invitación'
	   	@text = 'Has ganado ' + Wallet::COINS_PER_INVITATION.to_s + ' monedas!'
	   	Notification.create!(notification_type: @notification_type, user:  user.invited_by , title: @title , text: @text )
	end
	
  end
end
