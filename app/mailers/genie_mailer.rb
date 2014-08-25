class GenieMailer < ActionMailer::Base
  layout 'mail'

  def user_report_email(user, important_emails, auto_filed_emails, sent_emails_not_replied_to)
    @important_emails = important_emails
    @auto_filed_emails = auto_filed_emails
    @sent_emails_not_replied_to = sent_emails_not_replied_to

    email = mail(to: user.email, subject: "#{$config.service_name} - Your daily Genie Report!")
    #email.header['X-MC-Important'] = 'true'
    #email.header['X-MC-Tags'] = 'welcome_email'

    return email
  rescue Exception => ex
    log_email('GenieMailer.user_report_email FAILED!', "#{user.id} #{user.email}\r\n\r\n#{ex.log_message}")
  end
end
