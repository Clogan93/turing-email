class EmailsController < ApplicationController
  
  before_filter :load_email, only: %w(show update destroy)
  respond_to :json, :html

  def index
    @emails = Email.all

    respond_with @emails
  end

  def show
    respond_with @email
  end

  def update
    @email.update_column(:from_address, params[:email][:from_address])
    @email.update_column(:to_address, params[:email][:to_address])
    @email.update_column(:subject, params[:email][:subject])
    @email.update_column(:body, params[:email][:body])
    @email.update_column(:read, params[:email][:read])

    respond_with @email
  end

  def create
    @email = Email.create params[:email]

    respond_with @email
  end

  def destroy
    @email.destroy

    respond_with @email
  end

  private

  def load_email
    @email = Email.find params[:id]
  end

  def email_params
    params.require(:email).permit(:description, :status, :created_at, :updated_at)
  end

end
