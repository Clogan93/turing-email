class EmailInReplyTo < ActiveRecord::Base
  belongs_to :email_account, polymorphic: true
  belongs_to :email

  validates_presence_of(:email_account, :email, :in_reply_to_message_id)
end
