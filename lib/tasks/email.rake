desc "This task is called by the Heroku scheduler add-on"

task :sync_email => :environment do
  GmailAccount.all.each do |gmail_account|
    log_console("PROCESSING account #{gmail_account.email}")
    gmail_account.sync()
  end
end

task :email_genie => :environment do
  GmailAccount.all.each do |gmail_account|
    inbox_label = GmailLabel.where(:gmail_account => gmail_account,
                                   :label_id => 'INBOX').first
    next if inbox_label.nil?

    emails = inbox_label.emails.where('date < ?', Time.now - 24.hours)

    emails.each do |email|
      log_console("PROCESSING #{email.uid}")

      if EmailGenie.email_is_unimportant(email)
        log_console("#{email.uid} is UNIMPORTANT!!")

        EmailGenie.auto_file(email, inbox_label)
      end
    end
  end
end
