class GmailLabel < ActiveRecord::Base
  belongs_to :gmail_account

  has_many :email_folder_mappings,
           :as => :email_folder,
           :dependent => :destroy
  has_many :emails, :through => :email_folder_mappings

  validates_presence_of(:gmail_account_id, :label_id, :name, :label_type)
end
