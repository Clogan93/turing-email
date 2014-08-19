class Email < ActiveRecord::Base
  belongs_to :user
  belongs_to :email_account, polymorphic: true

  has_many :email_folder_mappings,
           :dependent => :destroy
  has_many :imap_folders, :through => :email_folder_mappings, :source => :email_folder, :source => 'ImapFolder'
  has_many :gmail_labels, :through => :email_folder_mappings, :source => :email_folder, :source_type => 'GmailLabel'

  validates_presence_of(:user, :email_account, :uid, :message_id)

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
    email = Email.new

    email.message_id = email_raw.message_id
    email.date = email_raw.date

    begin
      email.from_name = email_raw.header[:from].tree.addresses[0].name if email_raw.header[:from]
    rescue
      email.from_name = email_raw.from.match(/(.*) <.*>/)[1] if email_raw.from =~ /.* <.*>/
    end

    email.from_address = email_raw.from_addrs[0]

    email.tos = email_raw.to.join('; ') if !email_raw.to.blank?
    email.ccs = email_raw.cc.join('; ') if !email_raw.cc.blank?
    email.bccs = email_raw.bcc.join('; ') if !email_raw.bcc.blank?
    email.subject = email_raw.subject.nil? ? '' : email_raw.subject

    email.text_part = email_raw.text_part.decoded.force_utf8 if email_raw.text_part
    email.html_part = email_raw.html_part.decoded.force_utf8 if email_raw.html_part
    email.body_text = email_raw.decoded.force_utf8 if !email_raw.multipart? && email_raw.content_type =~ /text/i

    return email
  end
end
