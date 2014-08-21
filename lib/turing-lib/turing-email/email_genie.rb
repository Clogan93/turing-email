class EmailGenie
  LISTS = { '<sales@optimizely.com>' => 'Sales',
            '<press@optimizely.com>' => 'Press',
            '<marketing@optimizely.com>' => 'Marketing',
            '<visible-changes@optimizely.com>' => 'Visible Changes',
            '<events@optimizely.com>' => 'Events',
            '<archive@optimizely.com>' => 'Archive' }

  def EmailGenie.process_gmail_account(gmail_account)
    inbox_label = GmailLabel.where(:gmail_account => gmail_account,
                                   :label_id => 'INBOX').first
    return if inbox_label.nil?

    emails = inbox_label.emails.where('date < ?', Time.now - 24.hours)

    emails.each do |email|
      log_console("PROCESSING #{email.uid}")

      if EmailGenie.email_is_unimportant(email)
        log_console("#{email.uid} is UNIMPORTANT!!")

        EmailGenie.auto_file(email, inbox_label)
      end
    end
  end

  def EmailGenie.email_is_unimportant(email)
    if email.list_id && email.tos.downcase !~ /#{email.email_account.email}/
      log_console("UNIMPORTANT => list_id = #{email.list_id}")
      return true
    elsif EmailGenie.is_no_reply_address(email.reply_to_address) || EmailGenie.is_no_reply_address(email.from_address)
      log_console("UNIMPORTANT => NOREPLY = #{email.reply_to_address} #{email.from_address}")
      return true
    elsif email.from_address == 'calendar-notification@google.com' ||
          email.sender_address == 'calendar-notification@google.com' ||
          email.has_calendar_attachment
      log_console("UNIMPORTANT => Calendar!")
      return true
    end

    return false
  end

  def EmailGenie.is_no_reply_address(address)
    return (address =~ /.*no-?reply.*@.*/) != nil
  end

  def EmailGenie.auto_file(email, inbox_folder)
    log_console("AUTO FILING! #{email.uid}")

    EmailFolderMapping.destroy_all(:email => email, :email_folder => inbox_folder)

    if email.list_id
      log_console("Found list_id=#{email.list_id}")

      if EmailGenie::LISTS.keys.include?(email.list_id.downcase)
        email.email_account.move_email_to_folder(email, EmailGenie::LISTS[email.list_id.downcase])
      elsif email.from_address == 'notifications@github.com'
        email.email_account.move_email_to_folder(email, "GitHub/#{email.list_id}")
      else
        email.email_account.move_email_to_folder(email, 'List Emails')
      end
    else
      email.email_account.move_email_to_folder(email, 'Unimportant')
    end

    email.auto_filed = true
    email.save!
  end
end
