# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# Production only: credentials (and SendGrid) are unavailable without master.key
# in local Docker. Original code ran this in every environment:
# ActionMailer::Base.smtp_settings = {
#   :user_name => Rails.application.credentials.send_grid_username,
#   :password => Rails.application.credentials.send_grid_password,
#   :domain => 'teamtable-api.herokuapp.com',
#   :address => 'smtp.sendgrid.net',
#   :port => 587,
#   :authentication => :plain,
#   :enable_starttls_auto => true
# }
if Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    :user_name => Rails.application.credentials.send_grid_username,
    :password => Rails.application.credentials.send_grid_password,
    :domain => 'teamtable-api.herokuapp.com',
    :address => 'smtp.sendgrid.net',
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end
