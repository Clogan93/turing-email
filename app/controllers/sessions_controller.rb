class SessionsController < ApplicationController
  def new
  end

  def create
    user_signin_attempt(params[:session][:email], params[:session][:password])
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
