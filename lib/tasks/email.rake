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

    emails = inbox_label.where('date < ?', Time.now - 24.hours).count

    emails.each do |email|
      if EmailGenie.email_is_unimportant(email)
        EmailGenie.archive(email, inbox_label)
      end
    end
  end
end
