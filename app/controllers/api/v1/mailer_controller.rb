class Api::V1::MailerController < ApplicationController
	def send_request
		@user = User.find_by_id(params[:from_user_id])
		if  @user.present?
			@subject = "#{@user.nickname} te ha invitado a jugar a JugaPlay"

			if params[:to].present? and params[:from].present?
				params[:to].split(',').each do |to|
					InvitationsMailer.send_mail(to,params[:from],params[:content],params[:from_user_id],params[:sender_link], @subject).deliver_now
					SentMail.create!(from: params[:from], to: to, subject: @subject)
				end
			else
				return	render json: { errors: 'Parameters required: to and from' }
			end
		else
			return 	render json: { errors: 'Parameter :from_user_id is invalid' }
		end
	end
end
