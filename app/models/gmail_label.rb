class GmailLabel < ActiveRecord::Base
  belongs_to :gmail_account

  has_many :email_folder_mappings,
           :as => :email_folder,
           :dependent => :destroy
  has_many :emails, :through => :email_folder_mappings
  
  has_many :email_threads,
           :through => :emails

  has_many :auto_filed_emails,
           :as => :auto_filed_folder

  validates_presence_of(:gmail_account_id, :label_id, :name, :label_type)

  def num_threads
    return self.emails.pluck(:email_thread_id).uniq.count
  end

  def num_unread_threads
    return self.emails.where(:seen => false).pluck(:email_thread_id).uniq.count
  end

  # TODO create test method
  def get_paginated_threads(params, per_page: 50)
    email_thread_ids = self.emails.order('emails.date DESC').pluck(:email_thread_id).uniq()
    email_threads = EmailThread.get_threads_from_ids(email_thread_ids)
    email_threads = email_threads.paginate(:page => params[:page], :per_page => per_page)

    return email_threads
  end
end
