class StaticPagesController < ApplicationController
  before_action :signed_in_user,   only: [:inbox]

  def home
  end

  def inbox
    inbox_label = GmailLabel.where(:gmail_account => current_user.gmail_accounts.first,
                                   :label_id => 'INBOX').first
    @email_threads = inbox_label.nil? ? [] : inbox_label.get_paginated_threads(params)
  end
end
