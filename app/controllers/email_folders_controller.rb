class EmailFoldersController < ApplicationController
  before_action :signed_in_user
  before_action :correct_user,   only: [:show]

  respond_to :json, :html

  def index
    @gmail_labels = GmailLabel.where(:gmail_account => current_user.gmail_accounts.first)

    respond_with @gmail_labels
  end

  def show
    @threads_array = Email.get_threads_array_from_emails(@gmail_label.emails)
    respond_with @threads_array
  end

  private

  # Before filters

  def correct_user
    @gmail_label = GmailLabel.find_by(:id => params[:id])
    redirect_to(root_url) unless current_user?(@gmail_label.gmail_account.user)
  end
end
