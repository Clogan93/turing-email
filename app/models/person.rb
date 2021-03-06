class Person < ActiveRecord::Base
  belongs_to :email_account, polymorphic: true
  
  has_many :email_recipients,
           :dependent => :destroy

  validates_presence_of(:email_account, :email_address)

  before_validation {
    self.email_address = cleanse_email(self.email_address) if self.email_address
  }
end
