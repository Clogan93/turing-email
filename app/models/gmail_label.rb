class GmailLabel < ActiveRecord::Base
  @@skip_update_counts = false
  
  def GmailLabel.skip_update_counts
    @@skip_update_counts
  end

  def GmailLabel.skip_update_counts=(val)
    @@skip_update_counts = val
  end
  
  belongs_to :gmail_account

  has_many :email_folder_mappings,
           :as => :email_folder,
           :dependent => :destroy
  has_many :emails, :through => :email_folder_mappings
  
  has_many :email_threads,
           :through => :emails

  has_many :auto_filed_emails,
           :as => :auto_filed_folder

  validates_presence_of(:gmail_account_id, :label_id, :name, :label_type)
  
  def update_counts
    return if GmailLabel.skip_update_counts
    
    self.with_lock do
      self.update_num_unread_threads()

      self.num_threads = EmailFolderMapping.joins(:email).where(:email_folder => self).
                                            count('DISTINCT "emails"."email_thread_id"')
      self.save!
    end
  end
  
  def update_num_unread_threads()
    return if GmailLabel.skip_update_counts
    
    self.with_lock do
      self.num_unread_threads = EmailFolderMapping.joins(:email).where(:email_folder => self).
                                                   where('"emails"."seen" = ?',false).
                                                   count('DISTINCT "emails"."email_thread_id"')
      self.save!
    end
  end
  
  def get_sorted_paginated_threads(last_email_thread: nil, dir: 'DESC', threads_per_page: 50, log: false)
    num_rows = threads_per_page
    dir = 'DESC' if dir.blank?

    last_email_sql = ''
    query_params = []
    dir_op = dir.upcase == 'DESC' ? '<' : '>'
    
    if last_email_thread
      emails = last_email_thread.emails.order(:date => :desc)
      
      for email in emails
        if email.draft_id.nil?
          last_email = email
          break
        end
      end
      
      last_email = emails[0] if last_email.nil?

      query_params.push(last_email.date, last_email_thread.id, last_email.id)
    else
      if self.emails.count > 0
        max_date = self.emails.maximum(:date) + 1.second
      else
        max_date = DateTime.now()
      end
      
      query_params.push(max_date, -1, -1)
    end
      
    last_email_sql = <<last_email_sql
AND
(
  email_folder_mappings."folder_email_thread_date",
  email_folder_mappings."email_thread_id",
  email_folder_mappings."email_id"
)
#{dir_op}
(?, ?, ?)
last_email_sql
      
    last_email_sql_inner = <<last_email_sql_inner
AND 
(
  email_folder_mappings_inner."folder_email_thread_date",
  email_folder_mappings_inner."email_thread_id",
  email_folder_mappings_inner."email_id"
)
#{dir_op}
(
  recent_email_threads."folder_email_thread_date",
  recent_email_threads."email_thread_id",
  recent_email_threads."email_id"
)
last_email_sql_inner
    
    sql = <<sql
WITH RECURSIVE recent_email_threads AS (
    (SELECT email_folder_mappings."folder_email_thread_date" AS folder_email_thread_date,
            email_folder_mappings."email_thread_id" AS email_thread_id,
            email_folder_mappings."email_id" AS email_id,
            array[email_folder_mappings."email_thread_id"] AS seen
    FROM "email_folder_mappings" AS email_folder_mappings
    WHERE email_folder_mappings."email_folder_id" = #{self.id.to_i} AND
          email_folder_mappings."email_folder_type" = '#{self.class.to_s}'
          #{last_email_sql}
    ORDER BY email_folder_mappings."folder_email_thread_date" #{dir},
             email_folder_mappings."email_thread_id" #{dir},
             email_folder_mappings."email_id" #{dir}
    LIMIT 1)

    UNION ALL

    (SELECT email_folder_mappings_lateral."folder_email_thread_date" AS folder_email_thread_date,
            email_folder_mappings_lateral."email_thread_id" AS email_thread_id,
            email_folder_mappings_lateral."email_id" AS email_id,
            recent_email_threads."seen" || email_folder_mappings_lateral."email_thread_id"
    FROM recent_email_threads,
    LATERAL (SELECT email_folder_mappings_inner."folder_email_thread_date",
                    email_folder_mappings_inner."email_thread_id",
                    email_folder_mappings_inner."email_id"
            FROM "email_folder_mappings" AS email_folder_mappings_inner
            WHERE email_folder_mappings_inner."folder_email_draft_id" IS NULL AND
                  email_folder_mappings_inner."email_folder_id" = #{self.id.to_i} AND
                  email_folder_mappings_inner."email_folder_type" = '#{self.class.to_s}' AND
                  email_folder_mappings_inner."email_thread_id" <> ALL (recent_email_threads."seen")
                  #{last_email_sql_inner}
            ORDER BY email_folder_mappings_inner."folder_email_thread_date" #{dir},
                     email_folder_mappings_inner."email_thread_id" #{dir},
                     email_folder_mappings_inner."email_id" #{dir}
            LIMIT 1)
      AS email_folder_mappings_lateral
    WHERE array_upper(recent_email_threads."seen", 1) < #{num_rows})
)
SELECT email_threads.*
       FROM email_threads
       WHERE id IN (SELECT recent_email_threads."email_thread_id"
                    FROM recent_email_threads
                    LIMIT #{threads_per_page})
sql

    if log
      log_console(sql)
      log_console(query_params)
    end

    query_params.unshift(sql)
    email_threads = EmailThread.find_by_sql(query_params)
    email_threads = EmailThread.joins(:emails => :gmail_labels).
                                includes(:emails => :gmail_labels).
                                where(:id => email_threads).
                                order('"emails"."draft_id" NULLS FIRST, "emails"."date" DESC, "email_threads"."id" DESC')
    
    email_threads = email_threads.includes(:emails => [:email_attachments, :email_attachment_uploads])

    return email_threads
  end
  
  def apply_to_emails(email_ids)
    email_folder_mappings = []
    
    email_ids.each do |email_id|
      begin
        if email_id.class == Email
          email = email_id
          email_folder_mappings << EmailFolderMapping.find_or_create_by!(:email => email_id, :email_folder => self,
                                                                         :folder_email_thread_date => email.email_thread.emails.maximum(:date),
                                                                         :folder_email_date => email.date, :folder_email_draft_id => email.draft_id,
                                                                         :email_thread => email.email_thread)
        else
          email = Email.find_by(:id => email_id)
          next if email.nil?
          email_folder_mappings << EmailFolderMapping.find_or_create_by!(:email_id => email_id, :email_folder => self,
                                                                         :folder_email_thread_date => email.email_thread.emails.maximum(:date),
                                                                         :folder_email_date => email.date, :folder_email_draft_id => email.draft_id,
                                                                         :email_thread => email.email_thread)
        end
      rescue ActiveRecord::RecordNotUnique
        email_folder_mappings << nil
      end
    end
    
    return email_folder_mappings
  end
end
