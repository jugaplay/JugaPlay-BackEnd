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
	@t_prize = TPrize.joins(:t_prize).where(user: @user and t_prize.table_id: @table.id).first()
	
	
    mail to: @user.email, from: INFO_MAIL, subject: "Resultados de #{table.title}!" do |format|
      format.html { render 'mailer/results_mailer/send_results_message' }
    end
    
    @notification_type = NotificationType.where(name: 'challenge').first()
	if @t_prize.present?
    	@title = 'Ya están los resultados de ' + @table.title + '. Ganaste ' + @t_prize.coins + ' monedas. Felicitaciones!' 
    else
  		@title = 'Ya están los resultados de ' + @table.title + '. Ganaste 0 monedas. Suerte para la próxima!' 
    end
    
   	Notification.create!(notification_type: @notification_type, user: @user, title: @title )
   
    
  end
end
