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
    EmailGenie.process_gmail_account(gmail_account)
  end
end
