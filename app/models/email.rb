class Email < ActiveRecord::Base
  belongs_to :user
  belongs_to :email_account, polymorphic: true
  belongs_to :email_thread

  has_many :email_folder_mappings,
           :dependent => :destroy
  has_many :imap_folders, :through => :email_folder_mappings, :source => :email_folder, :source => 'ImapFolder'
  has_many :gmail_labels, :through => :email_folder_mappings, :source => :email_folder, :source_type => 'GmailLabel'

  has_many :email_references,
           :dependent => :destroy

  has_many :email_in_reply_tos,
           :dependent => :destroy

  validates_presence_of(:user, :email_account, :uid, :message_id, :email_thread_id)

  def Email.email_raw_from_mime_data(mime_data)
    mail_data_file = Tempfile.new('turing')
    mail_data_file.binmode

    mail_data_file.write(mime_data)
    mail_data_file.close()
    email_raw = Mail.read(mail_data_file.path)
    FileUtils.remove_entry_secure(mail_data_file.path)

    return email_raw
  end

  def Email.email_from_mime_data(mime_data)
    email_raw = Email.email_raw_from_mime_data(mime_data)
    return Email.email_from_email_raw(email_raw)
  end

  def Email.email_from_email_raw(email_raw)
    email = Email.new

    email.message_id = email_raw.message_id
    email.list_id = email_raw.header['List-ID'].decoded.force_utf8(true) if email_raw.header['List-ID']
    email.date = email_raw.date

    from_string = email_raw.from ? email_raw.from[0] : nil
    email.from_name, email.from_address = Email.parse_address_header(email_raw.header['from'], from_string)
    email.from_address = email_raw.from_addrs[0] if email.from_address.nil?

    sender_string = email_raw.sender ? email_raw.sender[0] : nil
    email.sender_name, email.sender_address = Email.parse_address_header(email_raw.header['sender'], sender_string)

    reply_to_string = email_raw.reply_to ? email_raw.reply_to[0] : nil
    email.reply_to_name, email.reply_to_address = Email.parse_address_header(email_raw.header['reply_to'], reply_to_string)

    email.tos = email_raw.to.join('; ') if !email_raw.to.blank?
    email.ccs = email_raw.cc.join('; ') if !email_raw.cc.blank?
    email.bccs = email_raw.bcc.join('; ') if !email_raw.bcc.blank?
    email.subject = email_raw.subject.nil? ? '' : email_raw.subject

    email.text_part = email_raw.text_part.decoded.force_utf8(true) if email_raw.text_part
    email.html_part = email_raw.html_part.decoded.force_utf8(true) if email_raw.html_part
    email.body_text = email_raw.decoded.force_utf8(true) if !email_raw.multipart? && email_raw.content_type =~ /text/i

    email.has_calendar_attachment = Email.part_has_calendar_attachment(email_raw)

    return email
  end

  def Email.parse_address_header(address_header, address_string = nil)
    name = address = nil

    if address_header
      log_exception(true) { name = address_header.tree.addresses[0].name }
      log_exception(true) { address = address_header.tree.addresses[0].address }
    end

    if name.nil? ||address.nil?
      if address_string =~ /.* <.*>/
        name = address_string.match(/(.*) <.*>/)[0] if name.nil?
        address = address_string.match(/(.*) <.*>/)[1] if address.nil?
      else
        address = address_string if address.nil?
      end
    end

    return name, address
  end

  def Email.part_has_calendar_attachment(part)
    return true if part.content_type =~ /text\/calendar/i

    part.parts.each do |current_part|
      return true if Email.part_has_calendar_attachment(current_part)
    end

    return false
  end

  def add_references(email_raw)
    return if email_raw.references.nil?

    if email_raw.references.class == String
      EmailReference.find_or_create_by!(:email_account => self.email_account, :email => self,
                                        :references_message_id => email_raw.references)
      return
    end

    email_raw.references.each do |references_message_id|
      begin
        EmailReference.find_or_create_by!(:email_account => self.email_account, :email => self,
                                          :references_message_id => references_message_id)
      rescue ActiveRecord::RecordNotUnique
      end
    end
  end

  def add_in_reply_tos(email_raw)
    return if email_raw.in_reply_to.nil?

    if email_raw.in_reply_to.class == String
      EmailInReplyTo.find_or_create_by!(:email_account => self.email_account, :email => self,
                                        :in_reply_to_message_id => email_raw.in_reply_to)
      return
    end

    email_raw.in_reply_to.each do |in_reply_to_message_id|
      begin
        EmailInReplyTo.find_or_create_by!(:email_account => self.email_account, :email => self,
                                          :in_reply_to_message_id => in_reply_to_message_id)
      rescue ActiveRecord::RecordNotUnique
      end
    end
  end
end
