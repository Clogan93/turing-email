class EmailsController < ApplicationController
  before_action :signed_in_user
  before_action :correct_user,   only: [:show, :update, :destroy]

  respond_to :json, :html

  def index
    inbox_label = GmailLabel.where(:gmail_account => current_user.gmail_accounts.first,
                                   :label_id => 'INBOX').first
    return {} if inbox_label.nil?

    emails = inbox_label.emails
    threads = {}

    emails.each do |email|
      threads[email.thread_id] = [] if threads[email.thread_id].nil?
      threads[email.thread_id].push(email)
    end

    @threads_array = []

    threads.each do |thread_id, emails|
      emails.sort! { |x, y| y.date <=> x.date }
      @threads_array.push(emails)
    end

    @threads_array.sort! { |x, y| y.first.date <=> x.first.date }

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
