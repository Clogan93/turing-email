# TODO write tests
class EmailGenie
  LISTS = { '<sales@optimizely.com' => 'Sales',
            '<press@optimizely.com' => 'Press',
            '<marketing@optimizely.com' => 'Marketing',
            '<visible-changes@optimizely.com' => 'Visible Changes',
            '<events@optimizely.com' => 'Events',
            '<archive@optimizely.com' => 'Archive',
            '<team@optimizely.com' => 'Team',
            '<team-sf@optimizely.com' => 'Team (SF)',
            '<team-ams@optimizely.com' => 'Team (AMS)',
            '<rocketship@optimizely.com' => 'Rocketship' }

  def EmailGenie.send_user_report_email(user, demo = false)
    inbox_label = user.gmail_accounts.first.inbox_folder
    if inbox_label
      where_clause = demo ? ['date > ?', Time.now - 24.hours] :
                            ['date < ? AND date > ?', Time.now - 7.hours, Time.now - 7.hours - 24.hours]
                     
      important_emails = inbox_label.emails.where(where_clause).order(:date => :desc)
    else
      important_emails = []
    end

    log_console("FOUND #{important_emails.count} IMPORTANT emails")

    sent_label = user.gmail_accounts.first.sent_folder
    if sent_label
      sent_emails_ids = sent_label.emails.
          where('date < ? AND date > ?', Time.now - 24.hours, Time.now - 24.hours * 7).
          order(:date => :desc).
          pluck(:email_id, :message_id)

      sent_emails_ids_transposed = sent_emails_ids.transpose()
      sent_emails_email_ids = sent_emails_ids_transposed[0]
      sent_emails_message_ids = sent_emails_ids_transposed[1]

      if sent_emails_message_ids.nil?
        sent_emails_not_replied_to = []
      else
        replied_to_message_ids = EmailInReplyTo.where(:email => user.emails,
                                                      :in_reply_to_message_id => sent_emails_message_ids).
            pluck(:in_reply_to_message_id)
        not_replied_to_message_ids = sent_emails_message_ids - replied_to_message_ids

        sent_emails_not_replied_to = user.emails.where(:message_id => not_replied_to_message_ids).order('date DESC')
      end
    else
      sent_emails_not_replied_to = []
    end

    log_console("FOUND #{sent_emails_not_replied_to.count} SENT emails AWAITING reply")

    auto_filed_emails = user.emails.where(:auto_filed => true, :auto_filed_reported => false).order(:date => :desc)
    log_console("FOUND #{auto_filed_emails.count} AUTO FILED emails")

    GenieMailer.user_report_email(user, important_emails, auto_filed_emails, sent_emails_not_replied_to).deliver()

    auto_filed_emails.update_all(:auto_filed_reported => true)
  end

  def EmailGenie.process_gmail_account(gmail_account, demo = false)
    inbox_label = gmail_account.inbox_folder
    return if inbox_label.nil?

    emails = demo ? inbox_label.emails : inbox_label.emails.where('date < ?', Time.now - 7.hours)

    sent_label = gmail_account.sent_folder
    top_lists_email_daily_average = Email.lists_email_daily_average(gmail_account.user, limit: 10).transpose()[0]
    
    emails.each do |email|
      log_console("PROCESSING #{email.uid}")

      if EmailGenie.email_is_unimportant(email, sent_label: sent_label)
        log_console("#{email.uid} is UNIMPORTANT!!")
    
        EmailGenie.auto_file(email, inbox_label, sent_label: sent_label, top_lists_email_daily_average: top_lists_email_daily_average)
      end
    end
  end

  def EmailGenie.is_no_reply_address(address)
    return (address =~ /.*no-?reply.*@.*/) != nil
  end
  
  def EmailGenie.is_no_reply_email(email)
    return EmailGenie.is_no_reply_address(email.reply_to_address) || EmailGenie.is_no_reply_address(email.from_address)
  end
  
  def EmailGenie.is_calendar_email(email)
    return email.from_address == 'calendar-notification@google.com' ||
           email.sender_address == 'calendar-notification@google.com' ||
           email.has_calendar_attachment
  end
  
  def EmailGenie.is_email_note_to_self(email)
    return email.from_address =~ /^(#{email.user.email}|#{email.email_account.email})$/i &&
           email.email_recipients.count == 1 &&
           email.email_recipients[0].person.email_address =~ /^(#{email.user.email}|#{email.email_account.email})$/i
  end
  
  def EmailGenie.is_automatic_reply_email(email)
    return email.subject && email.subject =~ /^(Automatic Reply|Out of Office)/i
  end

  def EmailGenie.is_unimportant_list_email(email)
    return email.list_id && email.tos && email.tos.downcase !~ /#{email.email_account.email}/
  end
  
  def EmailGenie.is_completed_conversation_email(email, sent_folder = nil)
    return email.seen && sent_folder &&
           EmailInReplyTo.find_by(:email => sent_folder.emails, :in_reply_to_message_id => email.message_id)
  end
  
  def EmailGenie.is_unimportant_group_email(email)
    return email.email_recipients.count >= 5
  end

  def EmailGenie.email_is_unimportant(email, sent_label: nil)
    email.user.genie_rules.each do |genie_rule|
      return false if genie_rule.from_address && genie_rule.from_address = email.from_address
      return false if genie_rule.to_address && email.email_recipients.joins(:person).pluck(:email_address).include?(genie_rule.to_address)
      return false if genie_rule.subject && email.subject =~ /.*#{genie_rule.subject}.*/i
      return false if genie_rule.list_id && email.list_id == genie_rule.list_id
    end
    
    if EmailGenie.is_calendar_email(email)
      log_console("UNIMPORTANT => Calendar!")
      return true
    elsif EmailGenie.is_email_note_to_self(email)
      log_console("UNIMPORTANT => email.from_address = #{email.from_address} email.tos = #{email.tos}")
      return true
    elsif EmailGenie.is_automatic_reply_email(email)
      log_console("UNIMPORTANT => subject = #{email.subject}")
      return true
    elsif EmailGenie.is_unimportant_list_email(email)
      log_console("UNIMPORTANT => list_id = #{email.list_id}")
      return true
    elsif EmailGenie.is_completed_conversation_email(email, sent_label)
      log_console("UNIMPORTANT => Email SEEN AND replied to!")
      return true
    elsif EmailGenie.is_unimportant_group_email(email)
      log_console("UNIMPORTANT => GROUP EMAIL! email_recipients.count = #{email.email_recipients.count}")
      return true
    elsif EmailGenie.is_no_reply_email(email)
      log_console("UNIMPORTANT => NOREPLY = #{email.reply_to_address} #{email.from_address}")
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

  def EmailGenie.auto_file(email, inbox_folder, sent_label: nil, top_lists_email_daily_average: nil)
    log_console("AUTO FILING! #{email.uid}")

    if EmailGenie.is_calendar_email(email)
      email.email_account.move_email_to_folder(email, folder_name: 'Unimportant/Calendar', set_auto_filed_folder: true)
    elsif EmailGenie.is_email_note_to_self(email)
      email.email_account.move_email_to_folder(email, folder_name: 'Unimportant/Notes to Self', set_auto_filed_folder: true)
    elsif EmailGenie.is_automatic_reply_email(email)
      email.email_account.move_email_to_folder(email, folder_name: 'Unimportant/Automatic Replies', set_auto_filed_folder: true)
    elsif EmailGenie.is_unimportant_list_email(email)
      log_console("Found list_id=#{email.list_id}")

      EmailGenie.auto_file_list_email(email, top_lists_email_daily_average: top_lists_email_daily_average)
    elsif EmailGenie.is_completed_conversation_email(email, sent_label)
      email.email_account.move_email_to_folder(email, folder_name: 'Unimportant/Completed Conversations', set_auto_filed_folder: true)
    elsif EmailGenie.is_unimportant_group_email(email)
      email.email_account.move_email_to_folder(email, folder_name: 'Unimportant/Group Conversations', set_auto_filed_folder: true)
    else
      email.email_account.move_email_to_folder(email, folder_name: 'Unimportant', set_auto_filed_folder: true)
    end

    email.auto_filed = true
    email.save!
  end
  
  def EmailGenie.auto_file_list_email(email, top_lists_email_daily_average: nil)
    subfolder = email.list_name
    subfolder = email.list_id if subfolder.nil?
    
    if EmailGenie::LISTS.keys.include?(email.list_id.downcase)
      email.email_account.move_email_to_folder(email, folder_name: EmailGenie::LISTS[email.list_id.downcase], set_auto_filed_folder: true)
    elsif email.from_address == 'notifications@github.com'
      email.email_account.move_email_to_folder(email, folder_name: "GitHub/#{subfolder}", set_auto_filed_folder: true)
    elsif top_lists_email_daily_average.include?(email.list_id)
      email.email_account.move_email_to_folder(email, folder_name: "List Emails/#{subfolder}", set_auto_filed_folder: true)
    else
      email.email_account.move_email_to_folder(email, folder_name: 'List Emails', set_auto_filed_folder: true)
    end
  end
end
