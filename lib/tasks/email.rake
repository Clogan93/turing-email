desc "Sync all email accounts"

task :sync_email => :environment do
  GmailAccount.all.each do |gmail_account|
    log_console("PROCESSING account #{gmail_account.email}")

    gmail_account.sync_email()
  end
end

desc "Sync all email accounts - inbox and sent folders only"

task :sync_email_inbox_and_sent => :environment do
  GmailAccount.all.each do |gmail_account|
    log_console("PROCESSING account #{gmail_account.email}")

    gmail_account.sync_email(include_inbox: true, include_sent: true)
  end
end

desc "Sync all email accounts - inbox folder only"

task :sync_email_inbox => :environment do
  GmailAccount.all.each do |gmail_account|
    log_console("PROCESSING account #{gmail_account.email}")

    gmail_account.sync_email(include_inbox: true)
  end
end

desc "Sync all email accounts - sent folder only"

task :sync_email_sent => :environment do
  GmailAccount.all.each do |gmail_account|
    log_console("PROCESSING account #{gmail_account.email}")

    gmail_account.sync_email(include_sent: true)
  end
end

desc "Sync all email accounts - labels only"

task :sync_labels => :environment do
  GmailAccount.all.each do |gmail_account|
    log_console("PROCESSING account #{gmail_account.email}")

    gmail_account.sync_labels()
  end
end

desc "Run the genie on all email accounts"

task :email_genie => :environment do
  GmailAccount.all.each do |gmail_account|
    log_console("PROCESSING account #{gmail_account.email}")

    EmailGenie.process_gmail_account(gmail_account)
  end
end

desc "Run genie reports for all accounts"

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
