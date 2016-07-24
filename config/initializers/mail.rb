if(Rails.env.production?)

  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.default_charset = "utf-8"  
  ActionMailer::Base.smtp_settings = {
    address:              ENV['MAILGUN_SMTP_SERVER'],
    port:                 ENV['MAILGUN_SMTP_PORT'],
    user_name:            ENV['MAILGUN_SMTP_LOGIN'],
    password:             ENV['MAILGUN_SMTP_PASSWORD'],
    domain:               ENV['MAILGUN_DOMAIN'],
    enable_starttls_auto: true,
    authentication:       :plain,
  }
end
