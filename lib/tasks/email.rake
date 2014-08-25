desc "This task is called by the Heroku scheduler add-on"

task :sync_email => :environment do
  GmailAccount.all.each do |gmail_account|
    log_console("PROCESSING account #{gmail_account.email}")

    gmail_account.sync_email()
  end
end

task :sync_labels => :environment do
  GmailAccount.all.each do |gmail_account|
    log_console("PROCESSING account #{gmail_account.email}")

    gmail_account.sync_labels()
  end
end

task :email_genie => :environment do
  GmailAccount.all.each do |gmail_account|
    log_console("PROCESSING account #{gmail_account.email}")

    EmailGenie.process_gmail_account(gmail_account)
  end
end

task :email_genie_reports => :environment do
  User.all.each do |user|
    log_console("PROCESSING user #{user.email}")

    inbox_label = GmailLabel.where(:gmail_account => user.gmail_accounts.first,
                                   :label_id => 'INBOX').first
    if inbox_label
      important_emails = inbox_label.emails
                                     .where('date < ? AND date > ?', Time.now - 7.hours, Time.now - 7.hours - 24.hours)
                                     .order(:date => :desc)
    else
      important_emails = []
    end

    log_console("FOUND #{important_emails.count} IMPORTANT emails")

    sent_label = GmailLabel.where(:gmail_account => user.gmail_accounts.first,
                                  :label_id => 'SENT').first
    if sent_label
      sent_emails_ids = sent_label.emails.
                                   where('date < ? AND date > ?', Time.now - 24.hours, Time.now - 24.hours * 7).
                                   order(:date => :desc).
                                   pluck(:email_id, :message_id)

      sent_emails_ids_transposed = sent_emails_ids.transpose()
      sent_emails_email_ids = sent_emails_ids_transposed[0]
      sent_emails_message_ids = sent_emails_ids_transposed[1]

      replied_to_message_ids = EmailInReplyTo.where(:email => user.emails,
                                                    :in_reply_to_message_id => sent_emails_message_ids).
                                              pluck(:in_reply_to_message_id)
      not_replied_to_message_ids = sent_emails_message_ids - replied_to_message_ids

      sent_emails_not_replied_to = user.emails.where(:message_id => not_replied_to_message_ids)
    else
      sent_emails_no_reply = []
    end

    auto_filed_emails = user.emails.where(:auto_filed => true, :auto_filed_reported => false).order(:date => :desc)
    log_console("FOUND #{auto_filed_emails.count} AUTO FILED emails")

    GenieMailer.user_report_email(user, important_emails, auto_filed_emails, sent_emails_not_replied_to).deliver()
  end
end
