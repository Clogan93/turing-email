class EmailFoldersControllerController < ApplicationController
  before_action :signed_in_user

  respond_to :json, :html

  def index
    @gmail_labels = GmailLabel.where(:gmail_account => current_user.gmail_accounts.first)

    respond_with @gmail_labels
  end
end
