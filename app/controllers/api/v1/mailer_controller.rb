class Api::V1::MailerController < ApplicationController
  
  def send_request
	
	@user = User.find(params[:from_user_id])
	@sender_link = params[:sender_link]
		
	params[:to].split(',').each do |to|
		InvitationsMailer.send_mail(to,params[:from],params[:content],params[:from_user_id],params[:sender_link]).deliver_now	  	
    end
      
  	#TODO CREAR EN TABLA LOS REGISTROS DE LOS MAILS ENVIADOS
  end

end
