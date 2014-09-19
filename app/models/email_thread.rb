class EmailThread < ActiveRecord::Base
  belongs_to :email_account, polymorphic: true

  has_many :emails,
           :dependent => :destroy

  validates_presence_of(:email_account, :uid)

  def EmailThread.get_threads_from_ids(ids)
    email_threads = EmailThread.includes(:emails).where(:id => ids)
    return email_threads
  end

  def user
    return self.email_account.user
  end
end
