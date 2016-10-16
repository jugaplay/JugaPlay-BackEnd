class Admin::SentMailsController < Admin::BaseController
  def index
  	@sent_mails = SentMail.all
  end
end
