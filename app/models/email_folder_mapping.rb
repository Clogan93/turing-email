class EmailFolderMapping < ActiveRecord::Base
  belongs_to :email
  belongs_to :email_thread
  belongs_to :email_folder, polymorphic: true

  validates_presence_of(:email_id, :email_thread_id, :email_folder_id, :email_folder_type)
  
  after_create {
    self.email_folder.update_counts()
  }

  after_destroy {
    self.email_folder.update_counts()
  }
end
