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

    mail to: @user.email, from: INFO_MAIL, subject: "Resultados de #{table.title}!" do |format|
      format.html { render 'mailer/results_mailer/send_results_message' }
    end
  end
end
