class ResultsMailer < ActionMailer::Base
  INFO_MAIL = 'info@jugaplay.com'

  layout false

  def self.for_table(table)
    table.plays.each do |play|
      send_results_message(table, play).deliver
    end
  end

  def send_results_message(table, play)
    @table = table
    @play = play
    @user = play.user
	  @user_prize = @user.prize_of_table(table)
    @points_calculator = PlayPointsCalculator.new

    mail to: @user.email, from: INFO_MAIL, subject: "Resultados de #{table.title}!" do |format|
      format.html { render 'mailer/results_mailer/send_results_message' }
    end
    
    @notification_type = NotificationType.where(name: 'result').first()
    
	if @user_prize.present?
    	@title = 'Saliste ' + @table.position(@user).to_s   + '° en ' +  @table.title  + '. Ganaste ' + @user_prize.coins.to_s  + ' monedas.'
    else
  		@title =  'Saliste ' + @table.position(@user).to_s   + '° en '  + @table.title + '. Ganaste 0 monedas. Suerte para la próxima!' 
    end
   	Notification.create!(notification_type: @notification_type, user: @user, title: @table.title, text: @title , action: %q[window.location='history.html';])
  end
end
