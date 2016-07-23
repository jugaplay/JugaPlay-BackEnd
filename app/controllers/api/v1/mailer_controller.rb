class Api::V1::MailerController < ApplicationController
  
  def send_request
	
	InvitationsMailer.send_mail(params[:to],params[:from],params[:content],params[:from_user_id],params[:sender_link]).deliver_now	  	
  
  end

end
