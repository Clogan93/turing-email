class EmailReference < ActiveRecord::Base
  belongs_to :email

  validates_presence_of(:email, :references_message_id)
end
