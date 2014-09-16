require 'base64'

class GmailAccount < ActiveRecord::Base
  MESSAGE_BATCH_SIZE = 10
  DRAFTS_BATCH_SIZE = 100
  HISTORY_BATCH_SIZE = 100
  SEARCH_RESULTS_PER_PAGE = 50

  belongs_to :user

  has_one :google_o_auth2_token,
          :as => :google_api,
          :dependent => :destroy

  has_many :email_threads,
           :as => :email_account,
           :dependent => :destroy

  has_many :emails,
           :as => :email_account,
           :dependent => :destroy
  
  has_many :people,
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

  def GmailAccount.email_raw_from_gmail_data(gmail_data)
    mime_data = GmailAccount.mime_data_from_gmail_data(gmail_data)
    return Email.email_raw_from_mime_data(mime_data)
  end

  def GmailAccount.email_from_gmail_data(gmail_data)
    mime_data = GmailAccount.mime_data_from_gmail_data(gmail_data)
    email = Email.email_from_mime_data(mime_data)

    GmailAccount.init_email_from_gmail_data(email, gmail_data)

    return email
  end

  def GmailAccount.init_email_from_gmail_data(email, gmail_data)
    email.uid = gmail_data['id']
    email.snippet = gmail_data['snippet']
  end
  
  def inbox_folder
    return self.gmail_labels.find_by_label_id('INBOX')
  end
  
  def sent_folder
    return self.gmail_labels.find_by_label_id('SENT')
  end

  def trash_folder
    return self.gmail_labels.find_by_label_id('TRASH')
  end

  def drafts_folder
    return self.gmail_labels.find_by_label_id('DRAFTS')
  end
  
  # TODO write tests
  def send_email(tos, ccs, bccs, subject, body, email_in_reply_to_uid = nil)
    email_raw, email_in_reply_to = Email.email_raw_from_params(tos, ccs, bccs, subject, body, email_in_reply_to_uid)
  
    if email_in_reply_to
      self.gmail_client.messages_send('me', :threadId => email_in_reply_to.email_thread.uid, :email_raw => email_raw)
    else
      self.gmail_client.messages_send('me', :email_raw => email_raw)
    end
  end
  
  # TODO write tests
  def get_draft_ids()
    log_console("GET DRAFTS\n")

    draft_ids = {}

    nextPageToken = nil

    while true
      drafts_list_data = self.gmail_client.drafts_list('me', pageToken: nextPageToken,
                                                       maxResults: GmailAccount::DRAFTS_BATCH_SIZE)
      drafts_data = drafts_list_data['drafts']
      log_console("GOT #{drafts_data.length} drafts")

      drafts_data.each do |draft_data|
        gmail_id = draft_data['message']['id']
        draft_id = draft_data['id']

        draft_ids[gmail_id] = draft_id
      end

      nextPageToken = drafts_list_data['nextPageToken']
      break if nextPageToken.nil?
    end

    return draft_ids
  end

  # TODO write tests
  def sync_draft_data(draft_data)
    draft_id = draft_data['id']
    gmail_id = draft_data['message']['id']
    sync_gmail_ids([gmail_id])
    draft_email = self.emails.find_by(:uid => gmail_id)
    
    return draft_id, draft_email
  end

  # TODO write tests
  def create_draft(tos, ccs, bccs, subject, body, email_in_reply_to_uid = nil)
    email_raw, email_in_reply_to = Email.email_raw_from_params(tos, ccs, bccs, subject, body, email_in_reply_to_uid)

    if email_in_reply_to
      draft_data = self.gmail_client.drafts_create('me', :threadId => email_in_reply_to.email_thread.uid, :email_raw => email_raw)
    else
      draft_data = self.gmail_client.drafts_create('me', :email_raw => email_raw)
    end
    
    return sync_draft_data(draft_data)
  end

  # TODO write tests
  def update_draft(draft_id, tos, ccs, bccs, subject, body, email_in_reply_to_uid = nil)
    email_raw, email_in_reply_to = Email.email_raw_from_params(tos, ccs, bccs, subject, body, email_in_reply_to_uid)

    if email_in_reply_to
      draft_data = self.gmail_client.drafts_update('me', draft_id,
                                                   :threadId => email_in_reply_to.email_thread.uid, :email_raw => email_raw)
    else
      draft_data = self.gmail_client.drafts_update('me', draft_id, :email_raw => email_raw)
    end

    return sync_draft_data(draft_data)
  end

  # TODO write tests
  def send_draft(draft_id)
    gmail_data = self.gmail_client.drafts_send('me', draft_id)
    
    gmail_id = gmail_data['id']
    sync_gmail_ids([gmail_id])
    email = self.emails.find_by(:uid => gmail_id)
    
    return email
  end
  
  def delete_o_auth2_token
    if self.google_o_auth2_token
      self.google_o_auth2_token.destroy()
      self.google_o_auth2_token = nil
    end
  end

  def gmail_client()
    @gmail_client = Google::GmailClient.new(self.google_o_auth2_token.api_client) if @gmail_client.nil?
    return @gmail_client
  end

  def init_email_from_gmail_data(email, gmail_data)
    GmailAccount.init_email_from_gmail_data(email, gmail_data)

    email.email_account = self
  end

  def gmail_data_from_gmail_id(gmail_id, format = 'raw')
    return self.gmail_client.messages_get('me', gmail_id, format: format)
  end

  def mime_data_from_gmail_id(gmail_id)
    gmail_data = self.gmail_data_from_gmail_id(gmail_id)
    return GmailAccount.mime_data_from_gmail_data(gmail_data)
  end

  def email_raw_from_gmail_id(gmail_id)
    mime_data = self.mime_data_from_gmail_id(gmail_id)
    return Email.email_raw_from_mime_data(mime_data)
  end

  def email_from_gmail_id(gmail_id)
    gmail_data = self.gmail_data_from_gmail_id(gmail_id, 'raw')
    email =  GmailAccount.email_from_gmail_data(gmail_data)
    self.init_email_from_gmail_data(email, gmail_data)

    return email
  end

  def refresh_user_info(api_client = nil, do_save = true)
    api_client = self.google_o_auth2_token.api_client() if api_client.nil?
    o_auth2_client = Google::OAuth2Client.new(api_client)
    userinfo_data = o_auth2_client.userinfo_get()

    self.google_id = userinfo_data['id']
    self.email = userinfo_data['email'].downcase
    self.verified_email = userinfo_data['verified_email']

    self.save! if do_save
  end

  def search_threads(query, nextPageToken = nil, max_results = GmailAccount::SEARCH_RESULTS_PER_PAGE)
    log_console("SEARCH threads query=#{query} nextPageToken=#{nextPageToken} max_results=#{max_results}")
    
    thread_uids = []

    threds_list_data = self.gmail_client.threads_list('me', maxResults: max_results,
                                                            pageToken: nextPageToken,
                                                            q: query, fields: 'nextPageToken,threads/id')

    threads_data = threds_list_data['threads']
    threads_data.each { |thread_data| thread_uids.push(thread_data['id']) }
    nextPageToken = threds_list_data['nextPageToken']

    log_console("FOUND #{threads_data.length} threads nextPageToken=#{nextPageToken}")

    return thread_uids, nextPageToken
  end

  def sync_email(labelIds: nil)
    log_console("SYNCING Gmail #{self.email}")

    if self.last_history_id_synced.nil?
      return self.sync_email_full(labelIds: labelIds)
    else
      return self.sync_email_partial()
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

    email.seen = !gmail_label_ids.include?('UNREAD')
    email.save!

    log_console("seen = #{email.seen}")

    gmail_label_ids.each do |gmail_label_id|
      next if gmail_label_id == 'UNREAD'

      if gmail_label_id == 'INBOX' && email.auto_filed
        log_console('SKIPPING INBOX label because UNIMPORTANT!')
        next
      end

      gmail_label = GmailLabel.where(:gmail_account => self, :label_id => gmail_label_id).first
      if gmail_label.nil?
        label_data = self.gmail_client.labels_get('me', gmail_label_id)
        gmail_label = self.sync_label_data(label_data)

        log_console("created #{gmail_label_id}")
      end

      self.apply_label_to_email(email, label_id: gmail_label.label_id, label_name: gmail_label.name)
    end
  end

  # polymorphic call
  def move_email_to_folder(email, folder_id: nil, folder_name: nil, set_auto_filed_folder: false)
    if folder_id.nil? && folder_name.nil?
      log_console("MOVING FAILED #{email.uid} TO folder_id AND folder_name are NIL!")
      return false
    end
    
    log_console("MOVING #{email.uid} TO folder_id=#{folder_id} folder_name=#{folder_name}")

    EmailFolderMapping.destroy_all(:email => email)
    self.apply_label_to_email(email, label_id: folder_id, label_name: folder_name, set_auto_filed_folder: set_auto_filed_folder)
    
    return true
  end

  def apply_label_to_email(email, label_id: nil, label_name: nil, set_auto_filed_folder: false)
    if label_id.nil? && label_name.nil?
      log_console("APPLY LABEL TO #{email.uid} FAILED label_id=#{label_id} label_name=#{label_name}")
      return false
    end
    
    log_console("APPLY LABEL TO #{email.uid} label_id=#{label_id} label_name=#{label_name}")

    gmail_label = GmailLabel.find_by(:gmail_account => self, :label_id => label_id) if label_id
    gmail_label = GmailLabel.find_by(:gmail_account => self,
                                     :name => label_name) if gmail_label.nil? && label_name

    if gmail_label.nil?
      log_console("LABEL DNE! Creating!!")

      gmail_label = GmailLabel.new()

      gmail_label.gmail_account = email.email_account
      gmail_label.label_id = label_id || SecureRandom.uuid()
      gmail_label.name = label_name || 'New Label'
      gmail_label.label_type = 'user'

      gmail_label.save!
    end

    gmail_label.apply_to_emails([email])

    if set_auto_filed_folder
      email.auto_filed_folder = gmail_label
      email.save!
    end
    
    return true
  end

  def sync_email_full(labelIds: nil)
    log_console("FULL SYNC with last_history_id_synced = #{self.last_history_id_synced}\n")

    num_emails_synced = 0
    nextPageToken = nil
    last_history_id_synced = nil

    while true
      gmail_ids = []

      log_console("SYNCING page = #{nextPageToken}")

      messages_list_data = self.gmail_client.messages_list('me', pageToken: nextPageToken,
                                                           labelIds: labelIds,
                                                           maxResults: Google::Misc::MAX_BATCH_REQUESTS)

      messages_data = messages_list_data['messages']
      log_console("GOT #{messages_data.length} messages\n")

      messages_data.each { |message_data| gmail_ids.push(message_data['id']) }

      if last_history_id_synced.nil?
        gmail_data = self.gmail_client.messages_get('me', gmail_ids.first, format: 'minimal', fields: 'historyId')
        last_history_id_synced = gmail_data['historyId']
      end

      self.sync_gmail_ids(gmail_ids)
      num_emails_synced += gmail_ids.length
      sleep(1)

      nextPageToken = messages_list_data['nextPageToken']
      break if nextPageToken.nil?
    end

    self.set_last_history_id_synced(last_history_id_synced)

    return num_emails_synced > 0
  end

  def sync_email_partial()
    log_console("PARTIAL SYNC with last_history_id_synced = #{self.last_history_id_synced}\n")

    num_emails_synced = 0
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

      num_emails_synced += gmail_ids.length
      log_console("GOT #{gmail_ids.length} messages\n")

      self.sync_gmail_ids(gmail_ids)
      self.set_last_history_id_synced(historys_data.last['id']) if !historys_data.empty?

      nextPageToken = history_list_data['nextPageToken']
      break if nextPageToken.nil?
    end
    
    return num_emails_synced > 0
  end

  def create_email_from_gmail_data(gmail_data)
    email_raw = GmailAccount.email_raw_from_gmail_data(gmail_data)
    email = Email.email_from_email_raw(email_raw)
    self.init_email_from_gmail_data(email, gmail_data)

    if email.message_id.nil?
      log_console('NO message_id - SKIPPING!!!!!')
      return
    end

    begin
      gmail_thread_id = gmail_data['threadId']

      email_thread = EmailThread.find_or_create_by!(:email_account => self,
                                                    :uid => gmail_thread_id)
      email_thread.with_lock do
        email_thread.email_account = self
        email.email_thread = email_thread
        email.save!

        email.with_lock do
          email.add_references(email_raw)
          email.add_in_reply_tos(email_raw)
          email.add_recipients(email_raw)
          email.add_attachments(email_raw)
        end
      end

      self.sync_email_labels(email, gmail_data['labelIds'])
    rescue ActiveRecord::RecordNotUnique => unique_violation
      raise unique_violation if unique_violation.message !~ /index_emails_on_email_account_type_and_email_account_id_and_uid/

      email = Email.find_by_uid(gmail_data['id'])
      raise 'AHHHHHHHHHH unique_violation but NO email?!' if email.nil?

      self.sync_email_labels(email, gmail_data['labelIds'])
    end
  end

  def update_email_from_gmail_data(gmail_data)
    email = Email.find_by_uid(gmail_data['id'])
    if email.nil?
      log_console('Email GONE!!!')
      return
    end

    self.sync_email_labels(email, gmail_data['labelIds'])
  end

  def sync_gmail_ids_batch_request()
    return Google::APIClient::BatchRequest.new() do |result|
      if result.error?
        if result.response.status == 404
          log_console("DELETED = #{result.request.parameters['id']}")
          Email.destroy_all(:email_account => self,
                            :uid => result.request.parameters['id'])
          next
        else
          raise Google::Misc.raise_exception(result)
        end
      end

      gmail_data = result.data
      log_console("SYNC PROCESSING message.id = #{gmail_data['id']}")

      if gmail_data['raw']
        self.create_email_from_gmail_data(gmail_data)
      else
        log_console('EXISTS - minimal update!')
        self.update_email_from_gmail_data(gmail_data)
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

  def sync_gmail_thread(gmail_thread_id)
    log_console("SYNCING gmail_thread_id = #{gmail_thread_id}")
    thread_data = self.gmail_client.threads_get('me', gmail_thread_id, fields: 'messages(id)')
    messages_data = thread_data['messages']
    log_console("thread has #{messages_data.length} messages!")

    gmail_ids = []
    messages_data.each { |message_data| gmail_ids.push(message_data['id']) }
    self.sync_gmail_ids(gmail_ids)
  end

  def set_last_history_id_synced(last_history_id_synced)
    self.last_history_id_synced = last_history_id_synced
    self.save!
    log_console("SET last_history_id_synced = #{self.last_history_id_synced}\n")
  end
end
