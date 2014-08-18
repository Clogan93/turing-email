desc "This task is called by the Heroku scheduler add-on"

task :sync_email => :environment do
  GmailAccount.each do |gmail_account|
    log_console("PROCESSING account #{gmail_account.email}")
    gmail_account.sync()
  end
end
