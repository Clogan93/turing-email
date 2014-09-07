class EmailAttachment < ActiveRecord::Base
  belongs_to :email
  
  validates_presence_of(:email, :file_size)
end
