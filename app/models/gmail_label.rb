class GmailLabel < ActiveRecord::Base
  belongs_to :gmail_account

  has_many :email_folder_mappings,
           :as => :email_folder,
           :dependent => :destroy
  has_many :emails, :through => :email_folder_mappings

  has_many :auto_filed_emails,
           :as => :auto_filed_folder

  validates_presence_of(:gmail_account_id, :label_id, :name, :label_type)

  def num_threads
    return self.emails.pluck(:email_thread_id).uniq.count
  end

  def num_unread_threads
    return self.emails.where(:seen => false).pluck(:email_thread_id).uniq.count
  end
end
