class EmailRecipient < ActiveRecord::Base
  belongs_to :email
  belongs_to :person

  enum :recipient_type => { :to => 0, :cc => 1, :bcc => 2 }

  validates_presence_of(:email_id, :person, :recipient_type)
end
