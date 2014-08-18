require 'base64'

class GmailAccount < ActiveRecord::Base
  belongs_to :user

  has_one :google_o_auth2_token,
          :as => :google_api,
          :dependent => :destroy

  has_many :emails,
           :as => :email_account,
           :dependent => :destroy

  validates_presence_of(:user, :google_id, :email, :verified_email)

  def GmailAccount.mime_data_from_message_data(message_data)
    message_json = JSON.parse(message_data.to_json())
    mime_data = Base64.urlsafe_decode64(message_json['raw'])
    log_console("mime_data.length = #{mime_data.length}")

    return mime_data
  end

  def GmailAccount.email_from_message_data(message_data)
    mime_data = GmailAccount.mime_data_from_message_data(message_data)
    email = Email.email_from_mime_data(mime_data)

    email.gmail_id = message_data['id']
    email.gmail_history_id = message_data['historyId']

    email.thread_id = message_data['threadId']

    email.snippet = message_data['snippet']

    return email
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
    log_console("SYNCING account #{self.email}")

    if self.last_history_id_synced.nil?
      self.full_sync()
    else
      self.partial_sync()
    end
  end

  def full_sync()
    log_console("FULL SYNC with last_history_id_synced = #{self.last_history_id_synced}")

    gmail = Google::Gmail.new(self.google_o_auth2_token.api_client)
    threads_list_data = gmail.threads_list('me', labelIds: 'INBOX', fields: 'nextPageToken,threads(id,historyId)')
    inbox_threads = threads_list_data['threads']

    log_console("got #{inbox_threads.length} threads!")
    log_console('')

    (inbox_threads.length - 1).downto(0).each do |inbox_thread_index|
      inbox_thread = inbox_threads[inbox_thread_index]
      thread_data = gmail.threads_get('me', inbox_thread['id'], fields: 'messages(id)')

      messages = thread_data['messages']

      log_console("processing #{inbox_thread_index} inbox_thread.id = #{inbox_thread['id']} with #{messages.length} messages!")

      batch_request = Google::APIClient::BatchRequest.new() do |result|
        message_data = result.data
        log_console("processing message.id = #{message_data['id']}")

        email = GmailAccount.email_from_message_data(message_data)
        email.user = self.user
        email.email_account = self

        begin
          email.save!
        rescue ActiveRecord::RecordNotUnique => unique_violation
          raise unique_violation if unique_violation.message !~ /index_emails_on_user_id_and_email_account_id_and_message_id/
        end
      end

      messages.each do |message|
        call = gmail.messages_get_call('me', message['id'], format: 'raw')
        batch_request.add(call)
      end

      self.google_o_auth2_token.api_client.execute!(batch_request)

      self.last_history_id_synced = inbox_thread['historyId']
      self.save!
      log_console("SET last_history_id_synced = #{self.last_history_id_synced}")
      log_console('')
    end
  end

  def partial_sync()
    log_console("PARTIAL SYNC with last_history_id_synced = #{self.last_history_id_synced}")
  end
end
