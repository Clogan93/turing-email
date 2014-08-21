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

    email_thread_ids = inbox_label.emails.pluck(:email_thread_id)
    @threads_array = EmailThread.get_threads_array_from_ids(email_thread_ids)

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
