class Api::V1::MailerController < ApplicationController
  
  def send_request
	
	@user = User.find(params[:from_user_id])
	@sender_link = params[:sender_link]
	@subject = "#{@user.nickname} te ha invitado a jugar a JugaPlay"
		
	params[:to].split(',').each do |to|
		InvitationsMailer.send_mail(to,params[:from],params[:content],params[:from_user_id],params[:sender_link], @subject).deliver_now	  	
		SentMail.create!(from: params[:from], to: to, subject: @subject)
    end
      
  end

end
