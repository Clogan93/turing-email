class EmailGenie
  LISTS = ['sales', 'press', 'marketing']

  def EmailGenie.email_is_unimportant(email)
    if email.list_id && email.tos.downcase !~ email.email_account.email
      return true
    end
  end

  def EmailGenie.archive(email, inbox_label)
    EmailFolderMapping.where(:email => email, :email_folder => inbox_label).destroy_all

    if email.list_id
      EmailGene::LISTS.each do |list|
          if email.list_id.downcase =~ /#{list}@optimizely.com/
            EmailGenie.apply_label_to_email(email, list.camelcase)
            break
          end
      end
    end
  end

  def EmailGenie.apply_label_to_email(email, label_name)
    gmail_label = GmailLabel.where(:gmail_account => email.email_account)
    if gmail_label.nil?
      gmail_label = GmailLabel.new()

      gmail_label.gmail_account = email.email_account
      gmail_label.label_id = label_name
      gmail_label.name = label_name
      gmail_label.label_type = 'user'

      gmail_label.save!
    end

    email.email_account.apply_label_to_email(:email, gmail_label)
  end
end