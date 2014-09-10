class StaticPagesController < ApplicationController
  before_action :signed_in_user, :except => [:home]

  def home
  end

  def mail
    inbox_label = GmailLabel.where(:gmail_account => current_user.gmail_accounts.first,
                                   :label_id => 'INBOX').first
    @email_threads = inbox_label.nil? ? [] : inbox_label.get_paginated_threads(params)
  end

  def mail2
    inbox_label = GmailLabel.where(:gmail_account => current_user.gmail_accounts.first,
                                   :label_id => 'INBOX').first
    @email_threads = inbox_label.nil? ? [] : inbox_label.get_paginated_threads(params)
  end

end
