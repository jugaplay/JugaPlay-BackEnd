class ResultsMailer < ActionMailer::Base
  INFO_MAIL = 'info@jugaplay.com'

  layout false

  def self.for_table(table)
    table.plays.each do |play|
      send_results_message(table, play).deliver_now
    end
  end

  def send_results_message(table, play)
    @table = table
    @play = play
    @user = play.user
	  @prize = play.prize
    @player_points_calculator = PlayerPointsCalculator.new

    mail to: @user.email, from: INFO_MAIL, subject: "Resultados de #{table.title}!" do |format|
      format.html { render 'mailer/results_mailer/send_results_message' }
    end

    notification_title = "{\"table\": \"#{table.title}\", \"type\": \"#{play.type}\"}"
    notification_text = "{\"position\": #{play.position}, \"earned_coins\": #{@prize.value}, \"type_of_prize\": #{@prize.currency} }"
    notification_action = "{\"table_id\": #{table.id}}"
   	Notification.result!(user: @user, title: notification_title, text: notification_text , action: notification_action)
  end
end
