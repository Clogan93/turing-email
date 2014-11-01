class SessionsController < ApplicationController
  def new
    redirect_to gmail_o_auth2_url(true)
  end

  def create
    redirect_to gmail_o_auth2_url(true)
    #user_signin_attempt(params[:session][:email], params[:session][:password])
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
