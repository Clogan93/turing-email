class GmailLabel < ActiveRecord::Base
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

  def num_threads
    return EmailFolderMapping.joins(:email).where(:email_folder => self).count('DISTINCT "emails"."email_thread_id"')
  end

  def num_unread_threads
    return EmailFolderMapping.joins(:email).where(:email_folder => self).where('"emails"."seen" = ?',false).count('DISTINCT "emails"."email_thread_id"')
  end
  
  def get_sorted_paginated_threads(page: 1, threads_per_page: 50)
    num_rows = page * threads_per_page

    sql = <<sql
WITH RECURSIVE recent_email_threads AS (
    (SELECT email_folder_mappings.email_thread_id AS email_thread_id, array[email_folder_mappings.email_thread_id] AS seen
            FROM "email_folder_mappings" AS email_folder_mappings
            WHERE email_folder_mappings."email_folder_id" = #{self.id.to_i} AND
                  email_folder_mappings."email_folder_type" = '#{self.class.to_s}'
            ORDER BY email_folder_mappings."folder_email_date" DESC, email_folder_mappings."email_id" DESC LIMIT 1)

    UNION ALL

    (SELECT email_folder_mappings_lateral.email_thread_id AS email_thread_id, recent_email_threads.seen || email_folder_mappings_lateral.email_thread_id
            FROM recent_email_threads,
            LATERAL (SELECT email_folder_mappings_inner.email_thread_id
                            FROM "email_folder_mappings" AS email_folder_mappings_inner
                            WHERE email_folder_mappings_inner.folder_email_draft_id IS NULL AND
                                  email_folder_mappings_inner."email_folder_id" = #{self.id.to_i} AND
                                  email_folder_mappings_inner."email_folder_type" = '#{self.class.to_s}' AND
                                  email_folder_mappings_inner.email_thread_id <> ALL (recent_email_threads.seen)
                            ORDER BY email_folder_mappings_inner."folder_email_date" DESC, email_folder_mappings_inner."email_id" DESC LIMIT 1) AS email_folder_mappings_lateral
            WHERE array_upper(recent_email_threads.seen, 1) < #{num_rows})
)
SELECT email_threads.*
       FROM email_threads
       WHERE id IN (SELECT recent_email_threads.email_thread_id
                    FROM recent_email_threads
                    LIMIT #{threads_per_page} OFFSET #{(page - 1) * threads_per_page})
sql

    email_threads = EmailThread.find_by_sql(sql)
    email_threads = EmailThread.joins(:emails => :gmail_labels).
                                includes(:emails => :gmail_labels).
                                where(:id => email_threads).order('"emails"."draft_id" NULLS FIRST, "emails"."date" DESC, "email_threads"."id" DESC')
    
    return email_threads
  end
  
  def apply_to_emails(email_ids)
    email_folder_mappings = []
    
    email_ids.each do |email_id|
      begin
        if email_id.class == Email
          email = email_id
          email_folder_mappings << EmailFolderMapping.find_or_create_by!(:email => email_id, :email_folder => self,
                                                                         :folder_email_date => email.date, :folder_email_draft_id => email.draft_id,
                                                                         :email_thread => email.email_thread)
        else
          email = Email.find(email_id)
          email_folder_mappings << EmailFolderMapping.find_or_create_by!(:email_id => email_id, :email_folder => self,
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
