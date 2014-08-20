class EmailGenie
  LISTS = { '<sales@optimizely.com>' => 'Sales',
            '<press@optimizely.com>' => 'Press',
            '<marketing@optimizely.com>' => 'Marketing',
            '<visible-changes@optimizely.com>' => 'Visible Changes',
            '<events@optimizely.com>' => 'Events',
            '<archive@optimizely.com>' => 'Archive' }

  def EmailGenie.email_is_unimportant(email)
    if email.list_id && email.tos.downcase !~ /#{email.email_account.email}/
      return true
    elsif email.from_address == 'calendar-notification@google.com'
      return true
    end

    return false
  end

  def EmailGenie.auto_file(email, inbox_folder)
    log_console("AUTO FILING! #{email.uid}")

    EmailFolderMapping.destroy_all(:email => email, :email_folder => inbox_folder)

    if email.list_id
      log_console("Found list_id=#{email.list_id}")

      if EmailGene::LISTS.keys.include?(email.list_id.downcase)
        email.email_account.move_email_to_folder(email, EmailGene::LISTS[email.list_id.downcase])
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
