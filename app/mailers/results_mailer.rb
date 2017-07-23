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

    currency_text = @prize.chips? ? 'fichas' : 'monedas'
    text = "Saliste #{play.position}° en #{@table.title }. Ganaste #{@prize} #{currency_text}."
    text += 'Suerte para la próxima!' if @prize.zero?
   	Notification.result!(user: @user, title: table.title, text: text , action: %q[window.location='history.html';])
  end
end
