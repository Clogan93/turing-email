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

  validates_presence_of(:user, :google_id, :email, :verified_email)

  def GmailAccount.mime_data_from_gmail_data(gmail_data)
    gmail_json = JSON.parse(gmail_data.to_json())
    mime_data = Base64.urlsafe_decode64(gmail_json['raw'])

    return mime_data
  end

  def GmailAccount.email_from_gmail_data(gmail_data)
    mime_data = GmailAccount.mime_data_from_gmail_data(gmail_data)
    email = Email.email_from_mime_data(mime_data)

    email.gmail_id = gmail_data['id']
    email.gmail_history_id = gmail_data['historyId']

    email.thread_id = gmail_data['threadId']

    email.snippet = gmail_data['snippet']

    return email
  end

  def gmail()
    @gmail = Google::Gmail.new(self.google_o_auth2_token.api_client) if @gmail.nil?
    return @gmail
  end

  def refresh_user_info(api_client = nil, do_save = true)
    api_client = self.google_o_auth2_token.api_client() if api_client.nil?
    oauth2 = Google::OAuth2.new(api_client)
    data = oauth2.userinfo_get()

    self.google_id = data['id']
    self.email = data['email'].downcase
    self.verified_email = data['verified_email']

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

  def full_sync()
    log_console("FULL SYNC with last_history_id_synced = #{self.last_history_id_synced}\n")

    gmail_ids = []
    nextPageToken = nil

    while true
      log_console("SYNCING page = #{nextPageToken}")

      messages_list_data = self.gmail.messages_list('me', labelIds: 'INBOX', pageToken: nextPageToken,
                                                    maxResults: Google::Misc::MAX_BATCH_REQUESTS)
      messages = messages_list_data['messages']
      log_console("GOT #{messages.count} messages\n")

      messages.each { |message| gmail_ids.push(message['id']) }

      nextPageToken = messages_list_data['nextPageToken']
      break if nextPageToken.nil?
    end

    gmail_ids = gmail_ids.reverse()
    self.sync_gmail_ids(gmail_ids, true)
  end

  def partial_sync()
    log_console("PARTIAL SYNC with last_history_id_synced = #{self.last_history_id_synced}\n")

    nextPageToken = nil

    while true
      log_console("SYNCING page = #{nextPageToken}")

      history_list_data = self.gmail.history_list('me', pageToken: nextPageToken,
                                                  startHistoryId: self.last_history_id_synced,
                                                  maxResults: GmailAccount::HISTORY_BATCH_SIZE)
      history_list = history_list_data['history']
      log_console("GOT #{history_list.length} history items")

      gmail_ids = []

      history_list.each do |history|
        messages = history['messages']
        messages.each { |message| gmail_ids.push(message['id']) }
      end

      log_console("GOT #{gmail_ids.length} messages\n")

      self.sync_gmail_ids(gmail_ids)
      self.set_last_history_id_synced(history_list.last['id']) if !history_list.empty?

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

        begin
          email.save!
        rescue ActiveRecord::RecordNotUnique => unique_violation
          raise unique_violation if unique_violation.message !~ /index_emails_on_user_id_and_email_account_id_and_message_id/
        end
      else
        log_console('EXISTS - minimal update!')
      end
    end
  end

  def sync_gmail_ids(gmail_ids, update_last_history_id_synced = false)
    gmail_id_index = 0

    while gmail_id_index < gmail_ids.length
      current_gmail_ids = gmail_ids[gmail_id_index ... (gmail_id_index + MESSAGE_BATCH_SIZE)]
      emails = Email.where(:gmail_id => current_gmail_ids)
      emails_by_gmail_id = {}
      emails.each { |email| emails_by_gmail_id[email.gmail_id] = email }

      batch_request = sync_gmail_ids_batch_request()

      current_gmail_ids.each do |gmail_id|
        format = emails_by_gmail_id.has_key?(gmail_id) ? 'minimal' : 'raw'
        log_console("QUEUEING message SYNC format=#{format} gmail_id = #{gmail_id}")

        call = self.gmail.messages_get_call('me', gmail_id, format: format)
        batch_request.add(call)
      end

      self.google_o_auth2_token.api_client.execute!(batch_request)

      if update_last_history_id_synced
        gmail_id = current_gmail_ids.last
        message_data = self.gmail.messages_get('me', gmail_id, format: 'minimal')

        self.set_last_history_id_synced(message_data['historyId'])
      end

      gmail_id_index += MESSAGE_BATCH_SIZE
    end
  end

  def set_last_history_id_synced(last_history_id_synced)
    self.last_history_id_synced = last_history_id_synced
    self.save!
    log_console("SET last_history_id_synced = #{self.last_history_id_synced}\n")
  end

  def full_sync_threads()
    threads_list_data = self.gmail.threads_list('me', labelIds: 'INBOX', fields: 'nextPageToken,threads(id,historyId)')
    threads = threads_list_data['threads']

    log_console("got #{threads.length} threads!\n")

    (threads.length - 1).downto(0).each do |thread_index|
      thread = threads[thread_index]
      self.sync_thread(thread['id'])

      self.set_last_history_id_synced(thread['historyId'])
    end
  end

  def sync_thread(thread_id)
    log_console("SYNCING thread.id = #{thread_id}")
    thread_data = self.gmail.threads_get('me', thread_id, fields: 'messages(id)')
    messages = thread_data['messages']
    log_console("thread has #{messages.length} messages!")

    gmail_ids = []
    messages.each { |message| gmail_ids.push(message['id']) }
    self.sync_gmail_ids(gmail_ids)
  end
end
