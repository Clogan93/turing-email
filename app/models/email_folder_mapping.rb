class EmailFolderMapping < ActiveRecord::Base
  belongs_to :email
  belongs_to :email_thread
  belongs_to :email_folder, polymorphic: true


  validates_presence_of(:email_id, :email_thread_id, :email_folder_id, :email_folder_type)
end
