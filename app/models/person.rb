class Person < ActiveRecord::Base
  belongs_to :email_account, polymorphic: true
  
  has_many :email_recipients,
           :dependent => :destroy

  validates_presence_of(:email_address)
end
