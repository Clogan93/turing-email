desc "This task is called by the Heroku scheduler add-on"

task :sync_email => :environment do
  GmailAccount.all.each do |gmail_account|
    log_console("PROCESSING account #{gmail_account.email}")

    gmail_account.sync_email()
  end
end

task :sync_email_inbox => :environment do
  GmailAccount.all.each do |gmail_account|
    log_console("PROCESSING account #{gmail_account.email}")

    gmail_account.sync_email(true)
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
    begin
      log_console("PROCESSING user #{user.email}")

      EmailGenie.send_user_report_email(user)
    rescue Exception => ex
      log_email_exception(ex)
    end
  end
end
