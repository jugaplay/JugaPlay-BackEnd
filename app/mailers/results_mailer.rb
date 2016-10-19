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
	  @coins = @user.earned_coins_in_table(table)
    @points_calculator = PlayPointsCalculator.new

    mail to: @user.email, from: INFO_MAIL, subject: "Resultados de #{table.title}!" do |format|
      format.html { render 'mailer/results_mailer/send_results_message' }
    end
    
    @notification_type = NotificationType.where(name: 'result').first
    
    @title = "Saliste #{@table.position(@user)}° en #{@table.title }. Ganaste #{@coins} monedas."
    @title += 'Suerte para la próxima!' if @coins.eql? 0

   	Notification.create!(notification_type: @notification_type, user: @user, title: @table.title, text: @title , action: %q[window.location='history.html';])
  end
end
