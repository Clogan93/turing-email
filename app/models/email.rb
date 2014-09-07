class Email < ActiveRecord::Base
  belongs_to :email_account, polymorphic: true
  belongs_to :email_thread
  
  belongs_to :ip_info

  belongs_to :auto_filed_folder, polymorphic: true

  has_many :email_folder_mappings,
           :dependent => :destroy
  has_many :imap_folders, :through => :email_folder_mappings, :source => :email_folder, :source_type => 'ImapFolder'
  has_many :gmail_labels, :through => :email_folder_mappings, :source => :email_folder, :source_type => 'GmailLabel'

  has_many :email_recipients,
           :dependent => :destroy
  
  has_many :email_references,
           :dependent => :destroy

  has_many :email_in_reply_tos,
           :dependent => :destroy
  
  has_many :email_attachments,
           :dependent => :destroy

  validates_presence_of(:email_account, :uid, :message_id, :email_thread_id)

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
    
    ip = Email.get_sender_ip(email_raw)
    email.ip_info = IpInfo.from_ip(ip) if ip

    email.message_id = email_raw.message_id
    email.list_id = email_raw.header['List-ID'].decoded.force_utf8(true) if email_raw.header['List-ID']
    email.date = email_raw.date

    from_addr = email_raw[:from].addrs[0] if email_raw[:from]
    email.from_name, email.from_address = from_addr.display_name, from_addr.address if from_addr

    sender_addr = email_raw[:sender].addrs[0] if email_raw[:sender]
    email.sender_name, email.sender_address = sender_addr.display_name, sender_addr.address if sender_addr

    reply_to_addr = email_raw[:reply_to].addrs[0] if email_raw[:reply_to]
    email.reply_to_name, email.reply_to_address = reply_to_addr.display_name, reply_to_addr.address if reply_to_addr
    
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

  def Email.get_sender_ip(email_raw)
    headers = parse_email_headers(email_raw.header.raw_source)
    headers.reverse!
    
    headers.each do |header|
      if header.name.downcase == 'x-originating-ip'
        m = header.value.match(/\[(#{$config.ip_regex})\]/)
        
        if m
          log_console("FOUND IP #{m[1]} IN X-Originating-IP=#{header.value}")
          return m[1]
        end
      elsif header.name.downcase == 'received'
        m = header.value.match(/from.*\[(#{$config.ip_regex})\]/)
        
        if m
          log_console("FOUND IP #{m[1]} IN RECEIVED=#{header.value}")
          return m[1]
        end
      elsif header.name.downcase == 'received-spf'
        m = header.value.match(/client-ip=(#{$config.ip_regex})/)

        if m
          log_console("FOUND IP #{m[1]} IN RECEIVED-SPF=#{header.value}")
          return m[1]
        end
      end
    end
    
    return nil
  end

  def Email.part_has_calendar_attachment(part)
    return true if part.content_type =~ /text\/calendar/i

    part.parts.each do |current_part|
      return true if Email.part_has_calendar_attachment(current_part)
    end

    return false
  end

  def user
    return self.email_account.user
  end

  def add_references(email_raw)
    return if email_raw.references.nil?

    if email_raw.references.class == String
      EmailReference.find_or_create_by!(:email => self, :references_message_id => email_raw.references)
      return
    end

    email_raw.references.each do |references_message_id|
      begin
        EmailReference.find_or_create_by!(:email => self, :references_message_id => references_message_id)
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
  
  # TODO write test
  def add_attachments(email_raw)
    if !email_raw.multipart? && email_raw.content_type && email_raw.content_type !~ /text/i
      self.add_attachment(email_raw)
    end

    email_raw.attachments.each do |attachment|
      self.add_attachment(attachment)
    end
  end

  # TODO write test
  def add_attachment(attachment)
    email_attachment = EmailAttachment.new
    
    email_attachment.email = self
    email_attachment.filename = attachment.filename
    email_attachment.content_type = attachment.content_type.split(';')[0].strip if attachment.content_type
    email_attachment.file_size = attachment.decoded.length
    
    email_attachment.save!
  end
  
  def add_recipients(email_raw)
    if email_raw[:to]
      email_raw[:to].addrs.each { |to_addr| self.add_recipient(to_addr, EmailRecipient.recipient_types[:to]) }
    end
    
    if email_raw[:cc]
      email_raw[:cc].addrs.each { |cc_addr| self.add_recipient(cc_addr, EmailRecipient.recipient_types[:cc]) }
    end

    if email_raw[:bcc]
      email_raw[:bcc].addrs.each { |cc_addr| self.add_recipient(cc_addr, EmailRecipient.recipient_types[:bcc]) }
    end
  end
  
  def add_recipient(addr, recipient_type)
    name, email_address = addr.display_name, addr.address

    person = nil
    while person.nil?
      begin
        person = Person.find_or_create_by!(:email_account => self.email_account,
                                           :email_address => cleanse_email(email_address))
      rescue ActiveRecord::RecordNotUnique
      end
    end

    person.name = name
    person.save!

    email_recipient = nil
    while email_recipient.nil?
      begin
        email_recipient = EmailRecipient.find_or_create_by!(:email => self, :person => person,
                                                            :recipient_type => recipient_type)
      rescue ActiveRecord::RecordNotUnique
      end
    end
  end
end
