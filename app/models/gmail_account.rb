require 'base64'

class GmailAccount < ActiveRecord::Base
  MESSAGE_BATCH_SIZE = 10
  HISTORY_BATCH_SIZE = 100

  belongs_to :user

  has_one :google_o_auth2_token,
          :as => :google_api,
          :dependent => :destroy

  has_many :emails,
           :as => :email_account,
           :dependent => :destroy

  has_many :gmail_labels,
           :dependent => :destroy

  validates_presence_of(:user, :google_id, :email, :verified_email)

  def GmailAccount.mime_data_from_gmail_data(gmail_data)
    gmail_json = JSON.parse(gmail_data.to_json())
    mime_data = Base64.urlsafe_decode64(gmail_json['raw'])

    return mime_data
  end

  def GmailAccount.email_from_gmail_data(gmail_data)
    mime_data = GmailAccount.mime_data_from_gmail_data(gmail_data)
    email = Email.email_from_mime_data(mime_data)

    email.uid = gmail_data['id']
    email.thread_id = gmail_data['threadId']
    email.snippet = gmail_data['snippet']

    return email
  end

  def gmail_client()
    @gmail_client = Google::GmailClient.new(self.google_o_auth2_token.api_client) if @gmail_client.nil?
    return @gmail_client
  end

  def mime_data_from_gmail_id(gmail_id)
    gmail_data = self.gmail_client.messages_get('me', gmail_id, format: 'raw')
    return GmailAccount.mime_data_from_gmail_data(gmail_data)
  end

  def refresh_user_info(api_client = nil, do_save = true)
    api_client = self.google_o_auth2_token.api_client() if api_client.nil?
    oauth2_client = Google::OAuth2Client.new(api_client)
    userinfo_data = oauth2_client.userinfo_get()

    self.google_id = userinfo_data['id']
    self.email = userinfo_data['email'].downcase
    self.verified_email = userinfo_data['verified_email']

    self.save! if do_save
  end

  def sync()
    log_console("SYNCING Gmail #{self.email}")

    if self.last_history_id_synced.nil?
      self.full_sync()
    else
      self.partial_sync()
    end
  end

  def sync_labels()
    log_console("SYNCING Gmail LABELS #{self.email}")

    labels_list_data = self.gmail_client.labels_list('me')
    labels_data = labels_list_data['labels']
    log_console("GOT #{labels_data.length} labels\n")

    labels_data.each { |label_data| self.sync_label_data(label_data) }
  end

  def sync_label_data(label_data)
    attempt = 0

    begin
      attempt += 1
      log_console("SYNCING Gmail LABEL #{label_data['id']} #{label_data['name']} #{label_data['type']}")

      gmail_label = GmailLabel.where(:gmail_account => self, :label_id => label_data['id']).first
      gmail_label = GmailLabel.new() if gmail_label.nil?

      gmail_label.gmail_account = self

      gmail_label.label_id = label_data['id']
      gmail_label.name = label_data['name']
      gmail_label.message_list_visibility = label_data['messageListVisibility']
      gmail_label.label_list_visibility = label_data['labelListVisibility']
      gmail_label.label_type = label_data['type']

      gmail_label.save!
    rescue ActiveRecord::RecordNotUnique => unique_violation
      log_console('UNIQUE violation!!')
      retry if attempt <= 1

      raise unique_violation
    end

    return gmail_label
  end

  def sync_email_labels(email, gmail_label_ids)
    log_console("SYNC LABELS for #{email.uid}")
    email.email_folder_mappings.destroy_all()

    email.seen = gmail_label_ids.include?('UNREAD')
    email.save!

    log_console("seen = #{email.seen}")

    gmail_label_ids.each do |gmail_label_id|
      next if gmail_label_id == 'UNREAD'

      gmail_label = GmailLabel.where(:gmail_account => self, :label_id => gmail_label_id).first
      if gmail_label.nil?
        label_data = self.gmail_client.labels_get('me', gmail_label_id)
        gmail_label = self.sync_label_data(label_data)

        log_console("created #{gmail_label_id}")
      end

      self.apply_label_to_email(email, gmail_label)
    end
  end

  def apply_label_to_email(email, gmail_label)
    log_console("APPLY #{gmail_label.name} TO #{email.uid}")

    begin
      email_folder_mapping = EmailFolderMapping.new()
      email_folder_mapping.email = email
      email_folder_mapping.email_folder = gmail_label
      email_folder_mapping.save!

      log_console("created email_folder_mapping.id=#{email_folder_mapping.id} FOR #{gmail_label_id}")
    rescue ActiveRecord::RecordNotUnique => unique_violation
      log_console('email_folder_mapping EXISTS!')
    end
  end

  def full_sync()
    log_console("FULL SYNC with last_history_id_synced = #{self.last_history_id_synced}\n")

    gmail_ids = []
    nextPageToken = nil

    while true
      log_console("SYNCING page = #{nextPageToken}")

      messages_list_data = self.gmail_client.messages_list('me', labelIds: 'INBOX', pageToken: nextPageToken,
                                                    maxResults: Google::Misc::MAX_BATCH_REQUESTS)
      messages_data = messages_list_data['messages']
      log_console("GOT #{messages_data.length} messages\n")

      messages_data.each { |message_data| gmail_ids.push(message_data['id']) }

      nextPageToken = messages_list_data['nextPageToken']
      break if nextPageToken.nil?
    end

    self.sync_gmail_ids(gmail_ids)

    gmail_data = self.gmail_client.messages_get('me', gmail_ids.first, format: 'minimal', fields: 'historyId')
    self.set_last_history_id_synced(gmail_data['historyId'])
  end

  def partial_sync()
    log_console("PARTIAL SYNC with last_history_id_synced = #{self.last_history_id_synced}\n")

    nextPageToken = nil

    while true
      log_console("SYNCING page = #{nextPageToken}")

      history_list_data = self.gmail_client.history_list('me', pageToken: nextPageToken,
                                                         startHistoryId: self.last_history_id_synced,
                                                         maxResults: GmailAccount::HISTORY_BATCH_SIZE)
      historys_data = history_list_data['history']
      log_console("GOT #{historys_data.length} history items")

      gmail_ids = []

      historys_data.each do |history_data|
        messages_data = history_data['messages']
        messages_data.each { |message_data| gmail_ids.push(message_data['id']) }
      end

      log_console("GOT #{gmail_ids.length} messages\n")

      self.sync_gmail_ids(gmail_ids)
      self.set_last_history_id_synced(historys_data.last['id']) if !historys_data.empty?

      nextPageToken = history_list_data['nextPageToken']
      break if nextPageToken.nil?
    end
  end

  def sync_gmail_ids_batch_request()
    return Google::APIClient::BatchRequest.new() do |result|
      raise result.error_message if result.error?

      gmail_data = result.data
      log_console("SYNC PROCESSING message.id = #{gmail_data['id']}")

      if gmail_data['raw']
        email = GmailAccount.email_from_gmail_data(gmail_data)
        email.user = self.user
        email.email_account = self

        if email.message_id.nil?
          log_console('NO message_id - SKIPPING!!!!!')
          next
        end

        begin
          email.save!
        rescue ActiveRecord::RecordNotUnique => unique_violation
          raise unique_violation if unique_violation.message !~ /index_emails_on_user_id_and_email_account_id_and_message_id/

          email = Email.find_by_uid(gmail_data['id'])
          raise 'AHHHHHHHHHH unique_violation but NO email?!' if email.nil?

          gmail_label_ids = gmail_data['labelIds']
          gmail_label_ids.delete('INBOX')
          self.sync_email_labels(email, gmail_label_ids)
        end

        self.sync_email_labels(email, gmail_data['labelIds'])
      else
        log_console('EXISTS - minimal update!')

        email = Email.find_by_uid(gmail_data['id'])
        if email.nil?
          log_console('Email GONE!!!')
          next
        end

        gmail_label_ids = gmail_data['labelIds']
        gmail_label_ids.delete('INBOX')
        self.sync_email_labels(email, gmail_label_ids)
      end
    end
  end

  def sync_gmail_ids(gmail_ids)
    gmail_id_index = 0

    while gmail_id_index < gmail_ids.length
      current_gmail_ids = gmail_ids[gmail_id_index ... (gmail_id_index + MESSAGE_BATCH_SIZE)]

      emails = Email.where(:uid => current_gmail_ids)
      emails_by_uid = {}
      emails.each { |email| emails_by_uid[email.uid] = email }

      batch_request = sync_gmail_ids_batch_request()

      current_gmail_ids.each do |gmail_id|
        format = emails_by_uid.has_key?(gmail_id) ? 'minimal' : 'raw'
        log_console("QUEUEING message SYNC format=#{format} gmail_id = #{gmail_id}")

        call = self.gmail_client.messages_get_call('me', gmail_id, format: format)
        batch_request.add(call)
      end

      self.google_o_auth2_token.api_client.execute!(batch_request)

      gmail_id_index += MESSAGE_BATCH_SIZE
    end
  end

  def set_last_history_id_synced(last_history_id_synced)
    self.last_history_id_synced = last_history_id_synced
    self.save!
    log_console("SET last_history_id_synced = #{self.last_history_id_synced}\n")
  end

  def full_sync_threads()
    threads_list_data = self.gmail_client.threads_list('me', labelIds: 'INBOX', fields: 'nextPageToken,threads(id,historyId)')
    threads_data = threads_list_data['threads']

    log_console("got #{threads_data.length} threads!\n")

    (threads_data.length - 1).downto(0).each do |thread_index|
      thread_data = threads_data[thread_index]
      self.sync_thread(thread_data['id'])

      self.set_last_history_id_synced(thread_data['historyId'])
    end
  end

  def sync_thread(thread_id)
    log_console("SYNCING thread.id = #{thread_id}")
    thread_data = self.gmail_client.threads_get('me', thread_id, fields: 'messages(id)')
    messages_data = thread_data['messages']
    log_console("thread has #{messages_data.length} messages!")

    gmail_ids = []
    messages_data.each { |message_data| gmail_ids.push(message_data['id']) }
    self.sync_gmail_ids(gmail_ids)
  end
end
