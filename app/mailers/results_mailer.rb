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
    @points_calculator = PlayPointsCalculator.new
	@t_prize = TPrize.joins(:prize).where("t_prizes.user_id= ? AND prizes.table_id = ?", @user.id, @table.id).first()
			
    mail to: @user.email, from: INFO_MAIL, subject: "Resultados de #{table.title}!" do |format|
      format.html { render 'mailer/results_mailer/send_results_message' }
    end
    
    @notification_type = NotificationType.where(name: 'challenge').first()
    
	if @t_prize.present?
    	@title = 'Saliste ' + @table.position(@user).to_s   + '° en ' +  @table.title  + '. Ganaste ' + @t_prize.coins.to_s  + ' monedas.' 
    else
  		@title =  'Saliste ' + @table.position(@user).to_s   + '° en '  + @table.title + '. Ganaste 0 monedas. Suerte para la próxima!' 
    end
       
    
   	Notification.create!(notification_type: @notification_type, user: @user, title: @table.title, text: @title , action: %q[window.location='history.html';])
   
    
  end
  
end
