require 'digest/sha2'
  
class InvitationsMailer < ActionMailer::Base
		
			
  def send_mail(to, from, content, from_user_id, sender_link, subject)
 
    @user = User.find(from_user_id)
	@sender_link = sender_link
	@params = content
	
	mail to: to, from: from,
      subject: subject do |format|
      format.html { render 'mailer/invitation_mailer/send_invitation_message' }
    end
    
  end
  
end
