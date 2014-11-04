desc 'Sync all email accounts'

task :sync_email, [:labelIds_string] => :environment do |t, args|
  args.with_defaults(:labelIds_string => nil)
  labelIds = nil
  labelIds = args.labelIds_string.split(' ') if args.labelIds_string
  
  GmailAccount.all.each do |gmail_account|
    begin
      log_console("PROCESSING account #{gmail_account.email}")
      
      gmail_account.sync_email(labelIds: labelIds)
    rescue Exception => ex
      log_email_exception(ex)
    end
  end
end

desc 'Sync all email accounts - labels only'

task :sync_labels => :environment do
  GmailAccount.all.each do |gmail_account|
    begin
      log_console("PROCESSING account #{gmail_account.email}")

      gmail_account.sync_labels()
    rescue Exception => ex
      log_email_exception(ex)
    end
  end
end

desc 'Run the genie on all email accounts'

task :email_genie, [:demo] => :environment do |t, args|
  args.with_defaults(:demo => false)
  
  GmailAccount.all.each do |gmail_account|
    begin
      log_console("PROCESSING account #{gmail_account.email}")
  
      EmailGenie.process_gmail_account(gmail_account, args.demo)

    rescue Exception => ex
      log_email_exception(ex)
    end
  end
end

desc 'Run genie reports for all accounts'

task :email_genie_reports, [:demo] => :environment do |t, args|
  args.with_defaults(:demo => false)
  
  User.all.each do |user|
    begin
      log_console("PROCESSING user #{user.email}")

      EmailGenie.send_user_report_email(user, args.demo)
    rescue Exception => ex
      log_email_exception(ex)
    end
  end
end

desc 'Reset the genie for testing purposes'

task :email_genie_reset => :environment do
  User.all.each do |user|
    begin
      email_ids_auto_filed = user.emails.where(:auto_filed => true).pluck(:id)
      log_console("FOUND #{email_ids_auto_filed.length} AUTO FILED!!")

      EmailFolderMapping.where(:email => email_ids_auto_filed).destroy_all
      inbox_label = user.gmail_accounts.first.inbox_folder
      
      email_ids_auto_filed.each do |email_id|
        begin
          EmailFolderMapping.find_or_create_by!(:email_folder => inbox_label, :email_id => email_id)
        rescue ActiveRecord::RecordNotUnique
        end
      end
      
      Email.where(:id => email_ids_auto_filed).update_all(:auto_filed => false, :auto_filed_reported => false,
                                                          :auto_filed_folder_id => nil, :auto_filed_folder_type => nil)
    rescue Exception => ex
      log_email_exception(ex)
    end
  end
end

desc 'Reset the genie report for testing purposes'

task :email_genie_reports_reset => :environment do
  User.all.each do |user|
    begin
      email_ids_auto_filed = user.emails.where(:auto_filed => true).pluck(:id)
      log_console("FOUND #{email_ids_auto_filed.length} AUTO FILED!!")
    
      Email.where(:id => email_ids_auto_filed).update_all(:auto_filed_reported => false)
        
      user.has_genie_report_ran = false
      user.save!
    rescue Exception => ex
      log_email_exception(ex)
    end
  end
end

desc 'Run email rules'

task :run_email_rules => :environment do
  User.all.each do |user|
    begin
      log_console("PROCESSING account #{user.email}")
      
      user.apply_email_rules_to_folder(user.email_account.inbox_folder)
    rescue Exception => ex
      log_email_exception(ex)
    end
  end
end
