class UsersController < ApplicationController
  before_action :signed_in_user, except: [:new, :create]
  before_action :correct_user,   only: [:edit, :update, :resend_verification_email]
  before_action :admin_user?,    only: :destroy

  def new
    if signed_in?
      flash[:info] = 'You already have an account!'

      redirect_to root_url
      return
    end

    @user = User.new
  end

  def create
    if signed_in?
      flash[:info] = 'You already have an account!'

      redirect_to root_url
      return
    end

    @user, success = User.create_from_post(params)

    if success
      sign_in @user

      flash[:success] = "Welcome to #{$config.service_name}!"
      redirect_to root_url
    else
      render 'new' # errors are rendered from @user
    end
  rescue ActiveRecord::RecordNotUnique => unique_violation
    flash.now[:danger] = User.get_unique_violation_error(unique_violation)

    render 'new'
  rescue Exception => ex
    log_email_exception(ex)
    @user.destroy if @user

    flash.now[:danger] = $config.error_message_default.html_safe
    render 'new'
  end

  def destroy
  end
  
  private

  # Before filters
  
  def correct_user
    @user = User.find_by(:id => params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
end
