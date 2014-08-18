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
    @email.update_column(:is_read, params[:email][:is_read])

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
end
