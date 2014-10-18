require 'base64'

class GmailAccount < ActiveRecord::Base
  MESSAGE_BATCH_SIZE = 100
  DRAFTS_BATCH_SIZE = 100
  HISTORY_BATCH_SIZE = 100
  SEARCH_RESULTS_PER_PAGE = 50
  NUM_SYNC_DYNOS = 2

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

  has_many :sync_failed_emails,
           :as => :email_account,
           :dependent => :destroy

  validates_presence_of(:user, :google_id, :email, :verified_email)

  # TODO write tests
  def GmailAccount.mime_data_from_gmail_data(gmail_data)
    gmail_json = JSON.parse(gmail_data.to_json())
    mime_data = Base64.urlsafe_decode64(gmail_json['raw'])

    return mime_data
  end

  # TODO write tests
  def GmailAccount.email_raw_from_gmail_data(gmail_data)
    mime_data = GmailAccount.mime_data_from_gmail_data(gmail_data)
    return Email.email_raw_from_mime_data(mime_data)
  end

  # TODO write tests
  def GmailAccount.email_from_gmail_data(gmail_data)
    mime_data = GmailAccount.mime_data_from_gmail_data(gmail_data)
    email = Email.email_from_mime_data(mime_data)

    GmailAccount.init_email_from_gmail_data(email, gmail_data)

    return email
  end

  # TODO write tests
  def GmailAccount.init_email_from_gmail_data(email, gmail_data)
    email.uid = gmail_data['id']
    email.snippet = gmail_data['snippet']
  end

  def gmail_client()
    return Google::GmailClient.new(self.google_o_auth2_token.api_client)
  end

  # TODO write tests
  def init_email_from_gmail_data(email, gmail_data)
    GmailAccount.init_email_from_gmail_data(email, gmail_data)

    email.email_account = self
  end

  # TODO write tests
  def gmail_data_from_gmail_id(gmail_id, format = 'raw')
    return self.gmail_client.messages_get('me', gmail_id, format: format)
  end

  # TODO write tests
  def mime_data_from_gmail_id(gmail_id)
    gmail_data = self.gmail_data_from_gmail_id(gmail_id)
    return GmailAccount.mime_data_from_gmail_data(gmail_data)
  end

  # TODO write tests
  def email_raw_from_gmail_id(gmail_id)
    mime_data = self.mime_data_from_gmail_id(gmail_id)
    return Email.email_raw_from_mime_data(mime_data)
  end

  # TODO write tests
  def email_from_gmail_id(gmail_id)
    gmail_data = self.gmail_data_from_gmail_id(gmail_id, 'raw')
    email =  GmailAccount.email_from_gmail_data(gmail_data)
    self.init_email_from_gmail_data(email, gmail_data)

    return email
  end

  def inbox_folder
    return self.gmail_labels.find_by_label_id('INBOX')
  end

  def sent_folder
    return self.gmail_labels.find_by_label_id('SENT')
  end

  def drafts_folder
    return self.gmail_labels.find_by_label_id('DRAFT')
  end

  def trash_folder
    return self.gmail_labels.find_by_label_id('TRASH')
  end

  def set_last_history_id_synced(last_history_id_synced)
    self.last_history_id_synced = last_history_id_synced
    self.save!
    log_console("SET last_history_id_synced = #{self.last_history_id_synced}\n")
  end
  
  def delete_o_auth2_token
    if self.google_o_auth2_token
      self.google_o_auth2_token.destroy()
      self.google_o_auth2_token = nil
    end
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

  def find_or_create_label(label_id: nil, label_name: nil)
    attempts = 1
    
    begin
      gmail_label = GmailLabel.find_by(:gmail_account => self, :label_id => label_id) if label_id
      gmail_label = GmailLabel.find_by(:gmail_account => self,
                                       :name => label_name) if gmail_label.nil? && label_name
  
      if gmail_label.nil?
        log_console("LABEL DNE! Creating!!")
  
        if label_id != 'TRASH' && !self.user.user_configuration.demo_mode_enabled
          label_data = self.gmail_client.labels_create('me', label_name || 'New Label')
          gmail_label = sync_label_data(label_data)
        else
          gmail_label = GmailLabel.create!(
            :gmail_account => self,
            :label_id => label_id || SecureRandom.uuid(),
            :name => label_name || 'New Label',
            :label_type => label_id == 'TRASH' ? 'system' : 'user'
          )
        end
      end
    rescue Google::APIClient::ServerError => ex
      if attempts == 1
        self.sync_labels()
  
        attempts += 1
        
        retry
      else
        raise ex
      end
    end
    
    return gmail_label
  end

  # polymorphic call 
  def emails_set_seen(emails, seen)
    if seen
      self.remove_emails_from_folder(emails, folder_id: 'UNREAD')
    else
      self.apply_label_to_emails(emails, label_id: 'UNREAD')
    end
    
    emails.update_all(:seen => seen)
  end
  
  # polymorphic call
  def trash_emails(emails)
    if !self.user.user_configuration.demo_mode_enabled
      gmail_client = self.gmail_client
      batch_request = Google::APIClient::BatchRequest.new()
    end

    emails.each do |email|
      call = self.trash_email(email, batch_request: true, gmail_client: gmail_client)
      batch_request.add(call) if !self.user.user_configuration.demo_mode_enabled
    end

    self.google_o_auth2_token.api_client.execute!(batch_request) if !self.user.user_configuration.demo_mode_enabled
  end

  # polymorphic call
  def trash_email(email, batch_request: false, gmail_client: nil)
    log_console("TRASHING #{email.uid}")

    EmailFolderMapping.where(:email => email).destroy_all()
    self.apply_label_to_email(email, label_id: 'TRASH', batch_request: batch_request, gmail_client: gmail_client)

    call = nil
    if !email.user.user_configuration.demo_mode_enabled
      gmail_client = self.gmail_client if gmail_client.nil?

      if batch_request
        call = gmail_client.messages_trash_call('me', email.uid)
      else
        gmail_client.messages_trash('me', email.uid)
      end
    end

    return call
  end

  # polymorphic call
  def remove_emails_from_folder(emails, folder_id: nil)
    if folder_id.nil?
      log_console("REMOVING FAILED #{email.uid} FROM folder_id IS NIL!")
      return false
    end

    if !self.user.user_configuration.demo_mode_enabled
      gmail_client = self.gmail_client
      batch_request = Google::APIClient::BatchRequest.new()
    end

    emails.each do |email|
      call = self.remove_email_from_folder(email, folder_id: folder_id,
                                           batch_request: true, gmail_client: gmail_client)

      batch_request.add(call) if !self.user.user_configuration.demo_mode_enabled
    end

    self.google_o_auth2_token.api_client.execute!(batch_request) if !self.user.user_configuration.demo_mode_enabled
  end

  # polymorphic call
  def remove_email_from_folder(email, folder_id: nil, batch_request: false, gmail_client: nil)
    if folder_id.nil?
      log_console("REMOVING FAILED #{email.uid} FROM folder_id IS NIL!")
      return false
    end

    log_console("REMOVING #{email.uid} FROM folder_id=#{folder_id}")

    email_folder = GmailLabel.find_by(:gmail_account => self, :label_id => folder_id)
    EmailFolderMapping.where(:email => email.id, :email_folder => email_folder).destroy_all if email_folder
    
    call = nil
    if !email.user.user_configuration.demo_mode_enabled
      gmail_client = self.gmail_client if gmail_client.nil?

      if batch_request
        call = gmail_client.messages_modify_call('me', email.uid, removeLabelIds: [folder_id])
      else
        gmail_client.messages_modify('me', email.uid, removeLabelIds: [folder_id])
      end
    end

    return call
  end

  # polymorphic call
  def move_emails_to_folder(emails, folder_id: nil, folder_name: nil, set_auto_filed_folder: false)
    if folder_id.nil? && folder_name.nil?
      log_console("MOVING FAILED #{email.uid} TO folder_id AND folder_name are NIL!")
      return false
    end

    if !self.user.user_configuration.demo_mode_enabled
      gmail_client = self.gmail_client
      batch_request = Google::APIClient::BatchRequest.new()
    end

    emails.each do |email|
      gmail_label, call = self.move_email_to_folder(email, folder_id: folder_id, folder_name: folder_name,
                                                    set_auto_filed_folder: set_auto_filed_folder,
                                                    batch_request: true, gmail_client: gmail_client)

      batch_request.add(call) if !self.user.user_configuration.demo_mode_enabled
    end

    self.google_o_auth2_token.api_client.execute!(batch_request) if !self.user.user_configuration.demo_mode_enabled
  end
  
  # polymorphic call
  def move_email_to_folder(email, folder_id: nil, folder_name: nil, set_auto_filed_folder: false,
                           batch_request: false, gmail_client: nil)
    if folder_id.nil? && folder_name.nil?
      log_console("MOVING FAILED #{email.uid} TO folder_id AND folder_name are NIL!")
      return false
    end

    log_console("MOVING #{email.uid} TO folder_id=#{folder_id} folder_name=#{folder_name}")

    if !email.user.user_configuration.demo_mode_enabled
      removeLabelIds = email.gmail_labels.pluck(:label_id)
      removeLabelIds.delete(folder_id)
      removeLabelIds.delete('SENT')
    end
    
    EmailFolderMapping.destroy_all(:email => email)
    gmail_label, ignore = self.apply_label_to_email(email, label_id: folder_id, label_name: folder_name,
                                                    set_auto_filed_folder: set_auto_filed_folder,
                                                    batch_request: batch_request, gmail_client: gmail_client)
    call = nil
    if !email.user.user_configuration.demo_mode_enabled
      gmail_client = self.gmail_client if gmail_client.nil?

      if batch_request
        call = gmail_client.messages_modify_call('me', email.uid,
                                                 addLabelIds: [gmail_label.label_id],
                                                 removeLabelIds: removeLabelIds)
      else
        gmail_client.messages_modify('me', email.uid,
                                     addLabelIds: [gmail_label.label_id],
                                     removeLabelIds: removeLabelIds)
      end
    end

    return [gmail_label, call]
  end

  def apply_label_to_emails(emails, label_id: nil, label_name: nil,
                            set_auto_filed_folder: false)
    if label_id.nil? && label_name.nil?
      log_console("APPLY LABEL TO #{email.uid} FAILED label_id=#{label_id} label_name=#{label_name}")
      return false
    end

    if !self.user.user_configuration.demo_mode_enabled
      gmail_client = self.gmail_client
      batch_request = Google::APIClient::BatchRequest.new()
    end
    
    emails.each do |email|
      gmail_label, call = self.apply_label_to_email(email, label_id: label_id, label_name: label_name,
                                                      set_auto_filed_folder: set_auto_filed_folder,
                                                      batch_request: true, gmail_client: gmail_client)
      
      batch_request.add(call) if !self.user.user_configuration.demo_mode_enabled
    end
    
    self.google_o_auth2_token.api_client.execute!(batch_request) if !self.user.user_configuration.demo_mode_enabled
  end
  
  def apply_label_to_email(email, label_id: nil, label_name: nil, set_auto_filed_folder: false,
                           batch_request: false, gmail_client: nil, gmail_sync: true)
    if label_id.nil? && label_name.nil?
      log_console("APPLY LABEL TO #{email.uid} FAILED label_id=#{label_id} label_name=#{label_name}")
      return nil
    end

    if label_id != 'UNREAD'
      gmail_label = self.find_or_create_label(label_id: label_id, label_name: label_name)
      gmail_label.apply_to_emails([email])

      label_id_final = gmail_label.label_id
    else
      gmail_label = nil
      label_id_final = label_id
    end

    call = nil
    if gmail_sync && !email.user.user_configuration.demo_mode_enabled && label_id_final != 'TRASH'
      gmail_client = self.gmail_client if gmail_client.nil?
      
      if batch_request
        call = gmail_client.messages_modify_call('me', email.uid, addLabelIds: [label_id_final])
      else
        gmail_client.messages_modify('me', email.uid, addLabelIds: [label_id_final])
      end
    end

    if set_auto_filed_folder
      email.auto_filed_folder = gmail_label
      email.save!
    end

    return [gmail_label, call]
  end

  def search_threads(query, nextPageToken = nil, max_results = GmailAccount::SEARCH_RESULTS_PER_PAGE)
    log_console("SEARCH threads query=#{query} nextPageToken=#{nextPageToken} max_results=#{max_results}")
    
    threds_list_data = self.gmail_client.threads_list('me', maxResults: max_results,
                                                            pageToken: nextPageToken,
                                                            q: query, fields: 'nextPageToken,threads/id')

    threads_data = threds_list_data['threads']
    thread_uids = threads_data.map { |thread_data| thread_data['id'] }
    nextPageToken = threds_list_data['nextPageToken']

    log_console("FOUND #{threads_data.length} threads nextPageToken=#{nextPageToken}")

    return thread_uids, nextPageToken
  end

  def process_sync_failed_emails(delay: true)
    log_console("process_sync_failed_emails #{self.sync_failed_emails.count} emails!")

    gmail_ids = self.sync_failed_emails.pluck(:email_uid)
    self.sync_failed_emails.where(:email_uid => gmail_ids).destroy_all()
    self.sync_gmail_ids(gmail_ids, delay: delay)
  end

  def sync_reset
    destroy_all_batch(self.emails)
    destroy_all_batch(self.gmail_labels)
    destroy_all_batch(self.sync_failed_emails)
    
    self.last_history_id_synced = nil
    
    self.save!
  end

  def sync_email(labelIds: nil, delay: true)
    log_console("SYNCING Gmail #{self.email}")
    
    self.process_sync_failed_emails(delay: delay)

    if self.last_history_id_synced.nil?
      synced_emails = self.sync_email_full(labelIds: labelIds, delay: delay)
      synced_emails = self.sync_email_partial(delay: delay) || synced_emails
      
      self.sync_draft_ids()
      
      return synced_emails
    else
      synced_emails = self.sync_email_partial(delay: delay)

      self.sync_draft_ids()
      
      return synced_emails 
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
    gmail_label = nil
    
    begin
      #log_console("SYNCING Gmail LABEL #{label_data['id']} #{label_data['name']} #{label_data['type']}")
      
      retry_block(sleep_seconds: 1) do
        gmail_label = GmailLabel.find_by(:gmail_account => self, :label_id => label_data['id'])
        gmail_label = GmailLabel.find_by(:gmail_account => self, :name => label_data['name']) if gmail_label.nil?
        gmail_label = GmailLabel.new(:gmail_account => self, :label_id => label_data['id']) if gmail_label.nil?

        gmail_label.label_id = label_data['id']
        gmail_label.name = label_data['name']
        gmail_label.message_list_visibility = label_data['messageListVisibility']
        gmail_label.label_list_visibility = label_data['labelListVisibility']
        gmail_label.label_type = label_data['type'] || 'user'
  
        gmail_label.save!
      end
    rescue ActiveRecord::RecordNotUnique => unique_violation
      log_console('UNIQUE violation!!')

      raise unique_violation
    end

    return gmail_label
  end
  
  def sync_email_labels(email, gmail_label_ids)
    #log_console("SYNC LABELS for #{email.uid}")
    email.email_folder_mappings.destroy_all()

    email.seen = !gmail_label_ids.include?('UNREAD')
    email.save!

    #log_console("seen = #{email.seen}")

    gmail_label_ids.each do |gmail_label_id|
      #log_console("SYNCING LABEL #{gmail_label_id}!")
      
      next if gmail_label_id == 'UNREAD'

      if gmail_label_id == 'INBOX' && email.auto_filed
        # TODO take out when syncing to Gmail!!
        log_console('SKIPPING INBOX label because AUTO FILED!')
        next
      end

      gmail_label = GmailLabel.find_by(:gmail_account => self, :label_id => gmail_label_id)
      if gmail_label.nil?
        label_data = self.gmail_client.labels_get('me', gmail_label_id)
        gmail_label = self.sync_label_data(label_data)

        log_console("created #{gmail_label_id}")
      end

      self.apply_label_to_email(email, label_id: gmail_label.label_id, label_name: gmail_label.name,
                                gmail_sync: false)
    end
  end

  def sync_email_full(labelIds: nil, delay: true)
    log_console("FULL SYNC with last_history_id_synced = #{self.last_history_id_synced}\n")

    num_emails_synced = 0
    nextPageToken = nil
    last_history_id_synced = nil

    while true
      log_console("SYNCING page = #{nextPageToken}")

      attempts = 0
      begin
        retry_block(log: true, exceptions_to_ignore: [Google::APIClient::ClientError]) do
          messages_list_data = self.gmail_client.messages_list('me', pageToken: nextPageToken, labelIds: labelIds,
                                                               maxResults: Google::Misc::MAX_BATCH_REQUESTS)
          messages_data = messages_list_data['messages']
          log_console("GOT #{messages_data.length} messages\n")
  
          gmail_ids = messages_data.map { |message_data| message_data['id'] }
    
          if last_history_id_synced.nil?
            gmail_data = self.gmail_client.messages_get('me', gmail_ids.first, format: 'minimal', fields: 'historyId')
            last_history_id_synced = gmail_data['historyId']
          end
    
          self.sync_gmail_ids(gmail_ids, delay: delay)
          num_emails_synced += gmail_ids.length
          
          nextPageToken = messages_list_data['nextPageToken']
        end
      rescue Google::APIClient::ClientError => ex
        attempts = Google::GmailClient.handle_client_error(ex, attempts)
        retry
      end
      
      sleep(1)
      
      break if nextPageToken.blank?
    end

    self.set_last_history_id_synced(last_history_id_synced)

    return num_emails_synced > 0
  rescue Exception => ex
    log_console('AHHHHHHH sync_email_full self.gmail_client.messages_list FAILED')
    raise ex
  end
  
  def sync_email_partial(delay: true)
    log_console("PARTIAL SYNC with last_history_id_synced = #{self.last_history_id_synced}\n")

    num_emails_synced = 0
    nextPageToken = nil

    while true
      log_console("SYNCING page = #{nextPageToken}")

      attempts = 0
      begin
        retry_block(log: true, exceptions_to_ignore: [Google::APIClient::ClientError]) do
          history_list_data = self.gmail_client.history_list('me', pageToken: nextPageToken,
                                                             startHistoryId: self.last_history_id_synced,
                                                             maxResults: GmailAccount::HISTORY_BATCH_SIZE)
          historys_data = history_list_data['history']
          log_console("GOT #{historys_data.length} history items")
    
          gmail_ids = []
    
          historys_data.each do |history_data|
            messages_data = history_data['messages']
            gmail_ids.concat(messages_data.map { |message_data| message_data['id'] })
          end
          
          log_console("GOT #{gmail_ids.length} messages\n")
    
          self.sync_gmail_ids(gmail_ids, delay: delay)
          num_emails_synced += gmail_ids.length
          
          self.set_last_history_id_synced(historys_data.last['id']) if !historys_data.empty?
          
          nextPageToken = history_list_data['nextPageToken']
        end
      rescue Google::APIClient::ClientError => ex
        attempts = Google::GmailClient.handle_client_error(ex, attempts)
        retry
      end

      sleep(1)
      
      break if nextPageToken.blank?
    end
    
    return num_emails_synced > 0
  rescue Exception => ex
    log_console('AHHHHHHH sync_email_partial self.gmail_client.history_list FAILED')
    raise ex
  end

  def create_email_from_gmail_data(gmail_data)
    email_raw = GmailAccount.email_raw_from_gmail_data(gmail_data)
    email = Email.email_from_email_raw(email_raw)
    self.init_email_from_gmail_data(email, gmail_data)

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
  rescue Exception => ex
    SyncFailedEmail.create_retry(self, gmail_data['id'], ex: ex)
  end

  def update_email_from_gmail_data(gmail_data)
    email = Email.find_by_uid(gmail_data['id'])
    if email.nil?
      log_email('Email GONE!!!')
      return
    end

    self.sync_email_labels(email, gmail_data['labelIds'])
  end

  def sync_gmail_ids_batch_request(delay: false)
    return Google::APIClient::BatchRequest.new() do |result|
      if result.error?
        if result.response.status == 404
          log_console("DELETED = #{result.request.parameters['id']}")
          Email.destroy_all(:email_account => self,
                            :uid => result.request.parameters['id'])
          next
        else
          SyncFailedEmail.create_retry(self, result.request.parameters['id'], result: result)
          next
        end
      end

      gmail_data = result.data
      log_console("SYNC PROCESSING message.id = #{gmail_data['id']}")

      begin
        if delay
          if gmail_data['raw']
            self.delay(heroku_scale: false).create_email_from_gmail_data(JSON.parse(gmail_data.to_json))
          else
            #log_console('EXISTS - minimal update!')
            self.delay(heroku_scale: false).update_email_from_gmail_data(JSON.parse(gmail_data.to_json))
          end
        else
          if gmail_data['raw']
            self.create_email_from_gmail_data(JSON.parse(gmail_data.to_json))
          else
            #log_console('EXISTS - minimal update!')
            self.update_email_from_gmail_data(JSON.parse(gmail_data.to_json))
          end
        end
      rescue Exception => ex
        SyncFailedEmail.create_retry(self, gmail_data['id'], ex: ex)
      end
    end
  end

  def sync_gmail_ids(gmail_ids, delay: false)
    gmail_id_index = 0

    while gmail_id_index < gmail_ids.length
      retry_block do
        current_gmail_ids = gmail_ids[gmail_id_index ... (gmail_id_index + GmailAccount::MESSAGE_BATCH_SIZE)]
        email_uids = Email.where(:uid => current_gmail_ids).pluck(:uid)
  
        batch_request = self.sync_gmail_ids_batch_request(delay: delay)
        gmail_client = self.gmail_client
  
        current_gmail_ids.each do |gmail_id|
          format = email_uids.include?(gmail_id) ? 'minimal' : 'raw'
          #log_console("QUEUEING message SYNC format=#{format} gmail_id = #{gmail_id}")
  
          call = gmail_client.messages_get_call('me', gmail_id, format: format)
          batch_request.add(call)
        end
  
        self.google_o_auth2_token.api_client.execute!(batch_request)
  
        gmail_id_index += GmailAccount::MESSAGE_BATCH_SIZE
      end
    end

    HerokuTools::HerokuTools.scale_dynos('worker', GmailAccount::NUM_SYNC_DYNOS) if delay
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

  def send_email(tos, ccs, bccs, subject, html_part, text_part, email_in_reply_to_uid = nil)
    email_raw, email_in_reply_to = Email.email_raw_from_params(tos, ccs, bccs, subject, html_part, text_part,
                                                               self, email_in_reply_to_uid)

    if email_in_reply_to
      gmail_data =
          self.gmail_client.messages_send('me', :threadId => email_in_reply_to.email_thread.uid, :email_raw => email_raw)
    else
      gmail_data = self.gmail_client.messages_send('me', :email_raw => email_raw)
    end

    gmail_id = gmail_data['id']
    sync_gmail_ids([gmail_id])
    email = self.emails.find_by(:uid => gmail_id)
    
    return email
  end

  def get_draft_ids()
    log_console("GET DRAFTS")

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
  def sync_draft_ids
    draft_ids = self.get_draft_ids()
    
    draft_ids.each do |gmail_id, draft_id|
      self.emails.where(:uid => gmail_id).update_all(:draft_id => draft_id)
    end
  end

  def sync_draft_data(draft_data)
    draft_id = draft_data['id']
    gmail_id = draft_data['message']['id']
    
    self.emails.where(:draft_id => draft_id).destroy_all()
    
    sync_gmail_ids([gmail_id])
    draft_email = self.emails.find_by(:uid => gmail_id)
    draft_email.draft_id = draft_id
    draft_email.save!

    return draft_email
  end

  def create_draft(tos, ccs, bccs, subject, html_part, text_part, email_in_reply_to_uid = nil)
    email_raw, email_in_reply_to = Email.email_raw_from_params(tos, ccs, bccs, subject, html_part, text_part,
                                                               self, email_in_reply_to_uid)

    if email_in_reply_to
      draft_data = self.gmail_client.drafts_create('me', :threadId => email_in_reply_to.email_thread.uid, :email_raw => email_raw)
    else
      draft_data = self.gmail_client.drafts_create('me', :email_raw => email_raw)
    end

    return sync_draft_data(draft_data)
  end

  def update_draft(draft_id, tos, ccs, bccs, subject, html_part, text_part)
    email = self.emails.find_by(:draft_id => draft_id)
    if email
      email_in_reply_to_uid = email.email_references.order(:position).last.email.uid if email.email_references.count > 0
      
      if email_in_reply_to_uid.nil?
        email_in_reply_to_uid = email.email_in_reply_tos.order(:position).last.email.uid if email.email_references.count > 0
      end
    end
    
    email_raw, email_in_reply_to = Email.email_raw_from_params(tos, ccs, bccs, subject, html_part, text_part,
                                                               self, email_in_reply_to_uid)

    if email_in_reply_to
      draft_data = self.gmail_client.drafts_update('me', draft_id,
                                                   :threadId => email_in_reply_to.email_thread.uid, :email_raw => email_raw)
    else
      draft_data = self.gmail_client.drafts_update('me', draft_id, :email_raw => email_raw)
    end

    return sync_draft_data(draft_data)
  end

  def send_draft(draft_id)
    gmail_data = self.gmail_client.drafts_send('me', draft_id)
    self.emails.where(:draft_id => draft_id).destroy_all if !draft_id.blank?

    gmail_id = gmail_data['id']
    sync_gmail_ids([gmail_id])
    email = self.emails.find_by(:uid => gmail_id)
    
    return email
  end
  
  def delete_draft(draft_id)
    self.gmail_client.drafts_delete('me', draft_id)
    email = self.emails.find_by(:draft_id => draft_id)
    email.destroy if email
  end
end
