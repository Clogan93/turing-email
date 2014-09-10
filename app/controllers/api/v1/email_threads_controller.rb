class Api::V1::EmailThreadsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_user, :except => [:inbox, :in_folder]

  swagger_controller :email_threads, 'Email Threads Controller'

  swagger_api :inbox do
    summary 'Return email threads in the inbox.'

    response :ok
  end

  def inbox
    inbox_label = GmailLabel.where(:gmail_account => current_user.gmail_accounts.first,
                                   :label_id => 'INBOX').first

    if inbox_label.nil?
      @email_threads = []
    else
      threads_per_page = 50

      page = params[:page]
      if page.blank?
        page = 1
      else
        page = page.to_i
      end
      
      num_rows = page * threads_per_page

      sql = <<sql
WITH RECURSIVE recent_email_threads AS (
    (SELECT emails.email_thread_id AS email_thread_id, array[emails.email_thread_id] AS seen
            FROM "emails" AS emails
            INNER JOIN "email_folder_mappings" AS email_folder_mappings ON emails."id" = email_folder_mappings."email_id"
            WHERE email_folder_mappings."email_folder_id" = #{inbox_label.id.to_i} AND email_folder_mappings."email_folder_type" = '#{inbox_label.class.to_s}'
            ORDER BY emails."date" DESC LIMIT 1)

    UNION ALL

    (SELECT emails_lateral.email_thread_id AS email_thread_id, recent_email_threads.seen || emails_lateral.email_thread_id
            FROM recent_email_threads,
            LATERAL (SELECT emails_inner.email_thread_id
                            FROM "emails" AS emails_inner
                            INNER JOIN "email_folder_mappings" AS email_folder_mappings_inner ON emails_inner."id" = email_folder_mappings_inner."email_id"
                            WHERE email_folder_mappings_inner."email_folder_id" = #{inbox_label.id.to_i} AND email_folder_mappings_inner."email_folder_type" = '#{inbox_label.class.to_s}' AND
                                  emails_inner.email_thread_id <> ALL (recent_email_threads.seen)
                            ORDER BY emails_inner."date" DESC LIMIT 1) AS emails_lateral
            WHERE array_upper(recent_email_threads.seen, 1) < #{num_rows})
)
SELECT email_threads.*
       FROM recent_email_threads
       INNER JOIN "email_threads" AS email_threads ON email_threads."id" = recent_email_threads.email_thread_id
       LIMIT #{threads_per_page} OFFSET #{(page - 1) * num_rows}
sql

      @email_threads = EmailThread.find_by_sql(sql)
      @email_threads = EmailThread.joins(:emails).includes(:emails).where(:id => @email_threads).order('"emails"."date" DESC')
    end

    render 'api/v1/email_threads/index'
  end

  swagger_api :in_folder do
    summary 'Return email threads in folder.'

    param :query, :folder_id, :string, :required, 'Email Folder ID'

    response :ok
    response $config.http_errors[:email_folder_not_found][:status_code],
             $config.http_errors[:email_folder_not_found][:description]
  end

  def in_folder
    @email_folder = GmailLabel.find_by(:gmail_account => current_user.gmail_accounts.first,
                                       :label_id => params[:folder_id])

    if @email_folder.nil?
      render :status => $config.http_errors[:email_folder_not_found][:status_code],
             :json => $config.http_errors[:email_folder_not_found][:description]
      return
    end
    
    email_thread_ids = @email_folder.emails.pluck(:email_thread_id)
    @email_threads = EmailThread.get_threads_from_ids(email_thread_ids)

    render 'api/v1/email_threads/index'
  end

  swagger_api :show do
    summary 'Return email thread.'

    param :path, :email_thread_uid, :string, :required, 'Email Thread UID'

    response :ok
    response $config.http_errors[:email_thread_not_found][:status_code],
             $config.http_errors[:email_thread_not_found][:description]
  end

  def show
  end

  private

  # Before filters

  def correct_user
    @email_thread = EmailThread.find_by(:email_account => current_user.gmail_accounts.first,
                                        :uid => params[:email_thread_uid])

    if @email_thread.nil?
      render :status => $config.http_errors[:email_thread_not_found][:status_code],
             :json => $config.http_errors[:email_thread_not_found][:description]
      return
    end
  end
end
