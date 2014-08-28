class EmailGenie
  LISTS = { '<sales.optimizely.com>' => 'Sales',
            '<press.optimizely.com>' => 'Press',
            '<marketing.optimizely.com>' => 'Marketing',
            '<visible-changes.optimizely.com>' => 'Visible Changes',
            '<events.optimizely.com>' => 'Events',
            '<archive.optimizely.com>' => 'Archive',
            '<team.optimizely.com>' => 'Team',
            '<team-sf.optimizely.com>' => 'Team (SF)',
            '<team-ams.optimizely.com>' => 'Team (AMS)',
            '<rocketship.optimizely.com>' => 'Rocketship' }

  def EmailGenie.send_user_report_email(user)
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
      sent_emails_not_replied_to = []
    end

    log_console("FOUND #{sent_emails_not_replied_to.count} SENT emails AWAITING reply")

    auto_filed_emails = user.emails.where(:auto_filed => true, :auto_filed_reported => false).order(:date => :desc)
    log_console("FOUND #{auto_filed_emails.count} AUTO FILED emails")

    GenieMailer.user_report_email(user, important_emails, auto_filed_emails, sent_emails_not_replied_to).deliver()

    auto_filed_emails.update_all(:auto_filed_reported => true)
  end

  def EmailGenie.process_gmail_account(gmail_account)
    inbox_label = GmailLabel.where(:gmail_account => gmail_account,
                                   :label_id => 'INBOX').first
    return if inbox_label.nil?

    emails = inbox_label.emails.where('date < ?', Time.now - 7.hours)

    sent_label = GmailLabel.where(:gmail_account => gmail_account,
                                  :label_id => 'SENT').first

    emails.each do |email|
      log_console("PROCESSING #{email.uid}")

      if EmailGenie.email_is_unimportant(email, sent_label)
        log_console("#{email.uid} is UNIMPORTANT!!")

        EmailGenie.auto_file(email, inbox_label)
      end
    end
  end

  def EmailGenie.email_is_unimportant(email, sent_label = nil)
    if email.list_id && email.tos && email.tos.downcase !~ /#{email.email_account.email}/
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
    elsif email.seen && EmailInReplyTo.find_by(:email_account => email.email_account,
                                               :in_reply_to_message_id => email.message_id)
      log_console("UNIMPORTANT => Email SEEN AND replied too!")
      return true
    elsif sent_label
      reply_address = email.reply_to_address ? email.reply_to_address : email.from_address

      num_emails_to_address = sent_label.emails.where('tos ILIKE ?', "%#{reply_address}%").count
      num_emails_from_address = Email.where("from_address=? OR reply_to_address=?",
                                            reply_address, reply_address).count

      ratio = num_emails_to_address / num_emails_from_address.to_f()
      if ratio < 0.1
        log_console("UNIMPORTANT => ratio = #{ratio} with reply_address = #{reply_address}!")
        return true
      end
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
        email.email_account.move_email_to_folder(email, EmailGenie::LISTS[email.list_id.downcase], true)
      elsif email.from_address == 'notifications@github.com'
        subfolder = email.list_id

        if subfolder =~ /.* <.*>/
          subfolder = subfolder.match(/(.*) <.*>/)[0]
        end

        email.email_account.move_email_to_folder(email, "GitHub/#{subfolder}", true)
      else
        email.email_account.move_email_to_folder(email, 'List Emails', true)
      end
    else
      email.email_account.move_email_to_folder(email, 'Unimportant', true)
    end

    email.auto_filed = true
    email.save!
  end
end
