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
    return self.emails.pluck(:email_thread_id).uniq.count
  end

  def num_unread_threads
    return self.emails.where(:seen => false).pluck(:email_thread_id).uniq.count
  end
  
  # TODO write test
  def get_sorted_paginated_threads(page: 1, threads_per_page: 50)
    num_rows = page * threads_per_page

    sql = <<sql
WITH RECURSIVE recent_email_threads AS (
    (SELECT emails.email_thread_id AS email_thread_id, array[emails.email_thread_id] AS seen
            FROM "emails" AS emails
            INNER JOIN "email_folder_mappings" AS email_folder_mappings ON emails."id" = email_folder_mappings."email_id"
            WHERE email_folder_mappings."email_folder_id" = #{self.id.to_i} AND
                  email_folder_mappings."email_folder_type" = '#{self.class.to_s}'
            ORDER BY emails."date" DESC LIMIT 1)

    UNION ALL

    (SELECT emails_lateral.email_thread_id AS email_thread_id, recent_email_threads.seen || emails_lateral.email_thread_id
            FROM recent_email_threads,
            LATERAL (SELECT emails_inner.email_thread_id
                            FROM "emails" AS emails_inner
                            INNER JOIN "email_folder_mappings" AS email_folder_mappings_inner ON emails_inner."id" = email_folder_mappings_inner."email_id"
                            WHERE email_folder_mappings_inner."email_folder_id" = #{self.id.to_i} AND
                                  email_folder_mappings_inner."email_folder_type" = '#{self.class.to_s}' AND
                                  emails_inner.email_thread_id <> ALL (recent_email_threads.seen)
                            ORDER BY emails_inner."date" DESC LIMIT 1) AS emails_lateral
            WHERE array_upper(recent_email_threads.seen, 1) < #{num_rows})
)
SELECT email_threads.*
       FROM recent_email_threads
       INNER JOIN "email_threads" AS email_threads ON email_threads."id" = recent_email_threads.email_thread_id
       LIMIT #{threads_per_page} OFFSET #{(page - 1) * threads_per_page}
sql

    email_threads = EmailThread.find_by_sql(sql)
    email_threads = EmailThread.joins(:emails).includes(:emails).where(:id => email_threads).order('"emails"."date" DESC')
    
    return email_threads
  end
  
  def apply_to_emails(email_ids)
    email_folder_mappings = []
    
    email_ids.each do |email_id|
      begin
        if email_id.class == Email
          email_folder_mappings << EmailFolderMapping.find_or_create_by!(:email => email_id, :email_folder => self)
        else
          email_folder_mappings << EmailFolderMapping.find_or_create_by!(:email_id => email_id, :email_folder => self)
        end
      rescue ActiveRecord::RecordNotUnique
        email_folder_mappings << nil
      end
    end
    
    return email_folder_mappings
  end
end
