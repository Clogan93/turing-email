class ImapFolder < ActiveRecord::Base
  belongs_to :email_account, polymorphic: true

  has_many :email_folder_mappings,
           :as => :email_folder,
           :dependent => :destroy
  has_many :emails, :through => :email_folder_mappings

  validates_presence_of(:email_account_id, :email_account_type, :name)
end
