class EmailInReplyTo < ActiveRecord::Base
  belongs_to :email

  validates_presence_of(:email, :in_reply_to_message_id)
end
