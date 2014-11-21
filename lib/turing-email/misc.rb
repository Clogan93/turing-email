def clear_email_tables
  [Email, ImapFolder, GmailLabel, EmailFolderMapping, EmailThread,
   EmailReference, EmailInReplyTo, IpInfo, Person, EmailRecipient, EmailAttachment,
   SyncFailedEmail, EmailTracker, EmailTrackerRecipient, EmailTrackerView, ListSubscription,
   Delayed::Job].each do |m|
    m.delete_all
  end
end
