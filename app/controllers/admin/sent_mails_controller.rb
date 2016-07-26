class Admin::SentMailsController < Admin::ApplicationController
 
  def index
  	@sent_mails = SentMail.all
  end

  
end
