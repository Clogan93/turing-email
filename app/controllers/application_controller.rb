class ApplicationController < ActionController::Base
  force_ssl if ENV['HEROKU'].to_i == 1

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper
  include ApplicationHelper

  before_action :authenticate

  rescue_from(Exception, :with => :render_exception) unless $config.consider_all_requests_local

  def render_exception(ex)
    log_email_exception(ex)
    raise ex
  end

  protected
  def skip_basic_auth?
    return Rails.env.development? || Rails.env.test?
  end

  def public_path?
    return false
  end

  def authenticate
    return if skip_basic_auth?() || public_path?()

    authenticate_or_request_with_http_basic do |username, password|
      username == 'streamline' && password == 'email'
    end
  end

  def admin_user?
    redirect_to(root_url) unless current_user && current_user.admin
  end
end
