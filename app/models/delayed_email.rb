# TODO write tests
class DelayedEmail < ActiveRecord::Base
  belongs_to :email_account, polymorphic: true
  belongs_to :delayed_job

  serialize :tos
  serialize :ccs
  serialize :bccs

  validates_presence_of(:email_account)
  
  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
  
  before_destroy {
    delayed_job = self.delayed_job
    delayed_job.destroy!()
  }
  
  def delayed_job()
    return Delayed::Job.find_by(:id => self.delayed_job_id)
  end

  def send_and_destroy()
    self.email_account.send_email(self.tos, self.ccs, self.bccs,
                                  self.subject,
                                  self.html_part, self.text_part,
                                  self.email_in_reply_to_uid,
                                  self.bounce_back_enabled, self.bounce_back_time, self.bounce_back_type)
    self.destroy!()
  end
  
  def send_at()
    delayed_job = self.delayed_job
    return delayed_job ? delayed_job.run_at : nil
  end
end
