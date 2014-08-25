class StaticPagesController < ApplicationController
  before_action :signed_in_user,   only: [:inbox, :email_threading_prototype]

  def home
  end

  def inbox
    inbox_label = GmailLabel.where(:gmail_account => current_user.gmail_accounts.first,
                                   :label_id => 'INBOX').first
    @email_threads = inbox_label.nil? ? [] : inbox_label.get_paginated_threads(params)
  end

  def email_threading_prototype
  end
  
  def api_docs
    render 'swagger_ui/_swagger_ui', :locals => {:discovery_url => '/api-docs/api-docs.json'}
  end
end
