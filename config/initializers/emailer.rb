# Email settings

RAILS_DEFAULT_LOGGER.debug("\n......initializer: emailer.rb........\n")


ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => "mail.nextdoorneighbors.org",
  :port => 25,
  :domain => "nextdoorneighbors.org",
  :authentication => :login,
  :user_name => "paul@ubuntu",
  :password => "Kgb0186"  
}
