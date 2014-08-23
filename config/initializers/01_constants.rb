$config = Rails.configuration
$url_helpers = Rails.application.routes.url_helpers
$helpers = ActionController::Base.helpers

# constants

ERROR = -1
OK = 1

# keys

$config.google_client_id ||= ENV['GOOGLE_CLIENT_ID']
$config.google_secret ||= ENV['GOOGLE_SECRET']

$config.mailgun_api_key ||= ENV['MAILGUN_API_KEY']
$config.mailgun_public_api_key ||= ENV['MAILGUN_PUBLIC_API_KEY']
$config.mailgun_smtp_username ||= ENV['MAILGUN_SMTP_USERNAME']
$config.mailgun_smtp_password ||= ENV['MAILGUN_SMTP_PASSWORD']

# http errors

$config.http_errors = {
    :already_have_account => {:status_code => 600, :description => 'You already have an account!'},
    :invalid_email_or_password => {:status_code => 601, :description => 'Invalid email or password.'},
    :email_in_use => {:status_code => 602, :description => 'Email in use.'},
    :account_locked => {:status_code => 603, :description => 'Account locked.'},

    :email_folder_not_found => {:status_code => 610, :description => 'Email folder not found.'},

    :email_not_found => {:status_code => 620, :description => 'Email not found.'}
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

# mailgun
$config.mailgun_smtp_server = 'smtp.mailgun.org'
$config.mailgun_api_url_base = "https://api:#{$config.mailgun_api_key}@api.mailgun.net/v2"
$config.mailgun_api_url = "#{$config.mailgun_api_url_base}/#{$config.mailgun_domain}"

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
