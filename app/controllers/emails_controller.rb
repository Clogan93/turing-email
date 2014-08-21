class EmailsController < ApplicationController
  before_action :signed_in_user
  before_action :correct_user,   only: [:show, :update, :destroy]

  respond_to :json, :html

  def index
    inbox_label = GmailLabel.where(:gmail_account => current_user.gmail_accounts.first,
                                   :label_id => 'INBOX').first
    if inbox_label.nil?
      respond_with nil
      return
    end

    emails = inbox_label.emails
    @threads_array = Email.get_threads_array_from_emails(emails)
    respond_with @threads_array
  end

  def show
    respond_with @email
  end

  def update
    @email.update_column(:seen, params[:email][:seen])

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

  # Before filters

  def correct_user
    @email = Email.find_by(:id => params[:id])
    redirect_to(root_url) unless current_user?(@email.user)
  end
end
