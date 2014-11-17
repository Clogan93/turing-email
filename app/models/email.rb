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
  
  has_many :email_tracker_recipients,
           :dependent => :destroy
  
  has_many :email_tracker_views,
           :through => :email_tracker_recipients
  
  belongs_to :list_subscription

  validates_presence_of(:email_account, :uid, :email_thread_id)

  after_create {
    EmailFolderMapping.where(:email_thread => self.email_thread).
                       update_all(:folder_email_thread_date => self.email_thread.emails.maximum(:date))
  }
  
  def Email.lists_email_daily_average(user, limit: nil, where: nil)
    return user.emails.where("list_id IS NOT NULL").where(where).
                group(:list_name, :list_id).order('daily_average DESC').limit(limit).
                pluck('list_name, list_id, COUNT(*) / (1 + EXTRACT(day FROM now() - MIN(date))) AS daily_average')
  end
  
  def Email.email_raw_from_params(tos = nil, ccs = nil, bccs = nil,
                                  subject = nil,
                                  html_part = nil, text_part = nil,
                                  email_account = nil, email_in_reply_to_uid = nil)
    email_raw = Mail.new do
      to tos
      cc ccs
      bcc bccs
      subject subject
    end

    email_raw.html_part = Mail::Part.new do
      content_type 'text/html; charset=UTF-8'
      body html_part
    end
    
    email_raw.text_part = Mail::Part.new do
      body text_part
    end

    email_in_reply_to = nil
    if !email_in_reply_to_uid.blank?
      email_in_reply_to = email_account.emails.includes(:email_thread).find_by(:uid => email_in_reply_to_uid)

      if email_in_reply_to
        log_console("FOUND email_in_reply_to=#{email_in_reply_to.id}")
        Email.add_reply_headers(email_raw, email_in_reply_to)
      end
    end
    
    return email_raw, email_in_reply_to
  end

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
    #email.ip_info = IpInfo.from_ip(ip) if ip

    email.message_id = email_raw.message_id

    if email_raw.header['List-ID']
      list_id_header_parsed = parse_email_list_id_header(email_raw.header['List-ID'])
      email.list_name = list_id_header_parsed[:name]
      email.list_id = list_id_header_parsed[:id]
    end

    email.date = email_raw.date

    froms_parsed = parse_email_address_field(email_raw, :from)
    if froms_parsed.length > 0
      email.from_name, email.from_address = froms_parsed[0][:display_name], froms_parsed[0][:address]
    end

    senders_parsed = parse_email_address_field(email_raw, :sender)
    if senders_parsed.length > 0
      email.sender_name, email.sender_address = senders_parsed[0][:display_name], senders_parsed[0][:address]
    end

    reply_tos_parsed = parse_email_address_field(email_raw, :reply_to)
    if reply_tos_parsed.length > 0
      email.reply_to_name, email.reply_to_address = reply_tos_parsed[0][:display_name], reply_tos_parsed[0][:address]
    end
    
    email.tos = email_raw.to.join('; ') if !email_raw.to.blank?
    email.ccs = email_raw.cc.join('; ') if !email_raw.cc.blank?
    email.bccs = email_raw.bcc.join('; ') if !email_raw.bcc.blank?
    email.subject = email_raw.subject.nil? ? '' : email_raw.subject

    email.text_part = email_raw.text_part.decoded.force_utf8(true) if email_raw.text_part
    email.html_part = premailer_html(email_raw.html_part.decoded).force_utf8(true) if email_raw.html_part

    if !email_raw.multipart? && (email_raw.content_type.nil? || email_raw.content_type =~ /text/i)
      email.body_text = email_raw.decoded.force_utf8(true)
    end

    email.has_calendar_attachment = Email.part_has_calendar_attachment(email_raw)

    return email
  end

  def Email.get_sender_ip(email_raw)
    headers = parse_email_headers(email_raw.header.raw_source)
    headers.reverse!
    
    headers.each do |header|
      next if header.name.nil? || header.value.nil?

      if header.name.downcase == 'x-originating-ip'
        m = header.value.match(/\[(#{$config.ip_regex})\]/)
        
        if m
          #log_console("FOUND IP #{m[1]} IN X-Originating-IP=#{header.value}")
          return m[1]
        end
      elsif header.name.downcase == 'received'
        m = header.value.match(/from.*\[(#{$config.ip_regex})\]/)
        
        if m
          #log_console("FOUND IP #{m[1]} IN RECEIVED=#{header.value}")
          return m[1]
        end
      elsif header.name.downcase == 'received-spf'
        m = header.value.match(/client-ip=(#{$config.ip_regex})/)

        if m
          #log_console("FOUND IP #{m[1]} IN RECEIVED-SPF=#{header.value}")
          return m[1]
        end
      end
    end
    
    return nil
  end

  def Email.part_has_calendar_attachment(part)
    return true if part.content_type =~ /text\/calendar|application\/ics/i

    part.parts.each do |current_part|
      return true if Email.part_has_calendar_attachment(current_part)
    end

    return false
  end

  def Email.add_reply_headers(email_raw, email_in_reply_to)
    email_raw.in_reply_to = "<#{email_in_reply_to.message_id}>" if !email_in_reply_to.message_id.blank?

    references_header_string = ''

    reference_message_ids = email_in_reply_to.email_references.order(:position).pluck(:references_message_id)
    if reference_message_ids.length > 0
      log_console("reference_message_ids.length=#{reference_message_ids.length}")

      references_header_string = '<' + reference_message_ids.join("><") + '>'
    elsif email_in_reply_to.email_in_reply_tos.count == 1
      log_console("email_in_reply_tos.count=#{email_in_reply_to.email_in_reply_tos.count}")

      references_header_string =
          '<' + email_in_reply_to.email_in_reply_tos.first.in_reply_to_message_id + '>'
    end

    references_header_string << "<#{email_in_reply_to.message_id}>" if !email_in_reply_to.message_id.blank?

    log_console("references_header_string = #{references_header_string}")

    email_raw.references = references_header_string
  end

  def user
    return self.email_account.user
  end

  def add_references(email_raw)
    return if email_raw.references.nil?

    if email_raw.references.class == String
      begin
        EmailReference.find_or_create_by!(:email => self, :references_message_id => email_raw.references,
                                          :position => 0)
      rescue ActiveRecord::RecordNotUnique
      end
      
      return
    end

    position = 0
    
    email_raw.references.each do |references_message_id|
      begin
        EmailReference.find_or_create_by!(:email => self, :references_message_id => references_message_id,
                                          :position => position)
      rescue ActiveRecord::RecordNotUnique
      end

      position += 1
    end
  end

  def add_in_reply_tos(email_raw)
    return if email_raw.in_reply_to.nil?

    if email_raw.in_reply_to.class == String
      begin
        EmailInReplyTo.find_or_create_by!(:email => self, :in_reply_to_message_id => email_raw.in_reply_to,
                                          :position => 0)
      rescue ActiveRecord::RecordNotUnique
      end
      
      return
    end

    position = 0
    
    email_raw.in_reply_to.each do |in_reply_to_message_id|
      begin
        EmailInReplyTo.find_or_create_by!(:email => self, :in_reply_to_message_id => in_reply_to_message_id,
                                          :position => 0)
      rescue ActiveRecord::RecordNotUnique
      end

      position += 1
    end
  end
  
  def add_attachments(email_raw)
    if !email_raw.multipart? && email_raw.content_type && email_raw.content_type !~ /text/i
      self.add_attachment(email_raw)
    end

    email_raw.attachments.each do |attachment|
      self.add_attachment(attachment)
    end
  end

  def add_attachment(attachment)
    email_attachment = EmailAttachment.new
    
    email_attachment.email = self
    email_attachment.filename = attachment.filename
    email_attachment.content_type = attachment.content_type.split(';')[0].downcase.strip if attachment.content_type
    email_attachment.file_size = attachment.decoded.length
    
    email_attachment.save!
  end
  
  def add_recipients(email_raw)
    tos_parsed = parse_email_address_field(email_raw, :to)
    tos_parsed.each { |to| self.add_recipient(to[:display_name], to[:address], EmailRecipient.recipient_types[:to]) }

    ccs_parsed = parse_email_address_field(email_raw, :cc)
    ccs_parsed.each { |cc| self.add_recipient(cc[:display_name], cc[:address], EmailRecipient.recipient_types[:cc]) }

    bccs_parsed = parse_email_address_field(email_raw, :bcc)
    bccs_parsed.each { |bcc| self.add_recipient(bcc[:display_name], bcc[:address], EmailRecipient.recipient_types[:bcc]) }
  end
  
  def add_recipient(name, email_address, recipient_type)
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
