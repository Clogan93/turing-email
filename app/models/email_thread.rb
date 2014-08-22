class EmailThread < ActiveRecord::Base
  belongs_to :user

  has_many :emails,
           :dependent => :destroy

  validates_presence_of(:user, :uid)

  def EmailThread.get_threads_from_ids(ids)
    email_threads = EmailThread.includes(:emails).where(:id => ids).order('emails.date DESC')
    return email_threads
  end
end
