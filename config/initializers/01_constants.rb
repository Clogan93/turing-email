$config = Rails.configuration
$url_helpers = Rails.application.routes.url_helpers
$helpers = ActionController::Base.helpers

# constants

ERROR = -1
OK = 1

# keys

$config.google_client_id ||= ENV['GOOGLE_CLIENT_ID']
$config.google_secret ||= ENV['GOOGLE_SECRET']

# http errors

$config.http_errors = {
    :already_have_account => {:status_code => 600, :description => 'You already have an account!'},
    :invalid_email_or_password => {:status_code => 601, :description => 'Invalid email or password.'},
    :email_in_use => {:status_code => 602, :description => 'Email in use.'},
    :account_locked => {:status_code => 603, :description => 'Account locked.'}
}

$config.company_name = 'Turing Technology, Inc.'
$config.service_name = 'Turing Email'
$config.service_name_short = 'Turing'

$config.email_domain = 'turinginc.com'

#$config.password_validation_regex = /\A(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}\z/
$config.email_validation_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

$config.support_email = "support@#{$config.email_domain}"
$config.logs_email = "logs@#{$config.email_domain}"

$config.support_email_name = "#{$config.service_name} (Support)"
$config.logs_email_name = "#{$config.service_name} Logs (#{Rails.env})"

$config.support_email_full = "#{$config.support_email_name} <#{$config.support_email}>"
$config.logs_email_full = "#{$config.logs_email_name} <#{$config.logs_email}>"

$config.error_message_repeat = "Please try again. If this keeps happening please email <a href=\"mailto:#{$config.support_email}\">#{$config.support_email}</a>"
$config.error_message_default = "There was an error. #{$config.error_message_repeat}"

$config.max_login_attempts = 5

=begin
$config.s3_key_length = 256
$config.s3_base_url = "https://s3.amazonaws.com/#{$config.s3_bucket}"

# keys

$config.aws_access_key_id ||= ENV['AWS_ACCESS_KEY_ID']
$config.aws_secret_access_key ||= ENV['AWS_SECRET_ACCESS_KEY']

# aws config
AWS.config(:access_key_id => $config.aws_access_key_id,
           :secret_access_key => $config.aws_secret_access_key)
=end
