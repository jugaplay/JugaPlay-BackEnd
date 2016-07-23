class InvitationsMailer < ActionMailer::Base
		
  def send_mail(to, from, content, from_user_id, sender_link)
	@user = User.find(from_user_id)
	@sender_link = sender_link
	mail to: to, from: from,
      subject: "#{@user.nickname} te ha invitado a jugar a JugaPlay" do |format|
      format.html { render 'mailer/invitation_mailer/send_invitation_message' }
    end
    
  end
  
end
