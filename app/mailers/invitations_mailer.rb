require 'digest/sha2'
  
class InvitationsMailer < ActionMailer::Base
		
   default "Message-ID"=>"#{Digest::SHA2.hexdigest(Time.now.to_i.to_s)}@jugaplay.com"
	
			
  def send_mail(to, from, content, from_user_id, sender_link)
 
   @user = User.find(from_user_id)
	@sender_link = sender_link
	
	mail to: to, from: from,
      subject: "#{@user.nickname} te ha invitado a jugar a JugaPlay" do |format|
      format.html { render 'mailer/invitation_mailer/send_invitation_message' }
    end
    
  end
  
end
