class Api::V1::EmailsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_user, :except => [:ip_stats, :volume_report, :contacts_report, :attachments_report, :lists_report]

  swagger_controller :emails, 'Emails Controller'

  swagger_api :show do
    summary 'Return email.'

    param :path, :email_uid, :string, :required, 'Email UID'

    response :ok
    response $config.http_errors[:email_not_found][:status_code], $config.http_errors[:email_not_found][:description]
  end

  def show
  end

  swagger_api :ip_stats do
    summary 'Return email sender IP stats.'

    response :ok
  end

  def ip_stats
    email_ip_info_counts = current_user.emails.group(:ip_info_id).count
    ip_infos = IpInfo.where(:id => email_ip_info_counts.keys)
    
    @email_ip_stats = []
    
    ip_infos.each do |ip_info|
      num_emails = email_ip_info_counts[ip_info.id]
      
      @email_ip_stats.push({ :num_emails => num_emails,
                             :ip_info =>ip_info })
    end
  end

  swagger_api :volume_report do
    summary 'Return email volume report stats.'

    response :ok
  end
  
  def volume_report
    sent_label = current_user.gmail_accounts.first.gmail_labels.find_by_label_id('SENT')
    sent_emails_ids = sent_label ? sent_label.emails.pluck(:id) : [-1]
    sent_emails_ids = [-1] if sent_emails_ids.empty?
    
    volume_report_stats = {
      :received_emails_per_month =>
          current_user.emails.where('"emails"."id" NOT IN (?)', sent_emails_ids).
                       group("DATE_TRUNC('month', date)").order('date_trunc_month_date DESC').limit(12).count,
      :received_emails_per_week =>
          current_user.emails.where('"emails"."id" NOT IN (?)', sent_emails_ids).
                       group("DATE_TRUNC('week', date)").order('date_trunc_week_date DESC').limit(12).count,
      :received_emails_per_day =>
          current_user.emails.where('"emails"."id" NOT IN (?)', sent_emails_ids).
                       group("DATE_TRUNC('day', date)").order('date_trunc_day_date DESC').limit(30).count,

      :sent_emails_per_month =>
          current_user.emails.where('"emails"."id" IN (?)', sent_emails_ids).
                       group("DATE_TRUNC('month', date)").order('date_trunc_month_date DESC').limit(12).count,
      :sent_emails_per_week =>
          current_user.emails.where('"emails"."id" IN (?)', sent_emails_ids).
                       group("DATE_TRUNC('week', date)").order('date_trunc_week_date DESC').limit(12).count,
      :sent_emails_per_day =>
          current_user.emails.where('"emails"."id" IN (?)', sent_emails_ids).
                       group("DATE_TRUNC('day', date)").order('date_trunc_day_date DESC').limit(30).count
    }

    volume_report_stats_short = {}
    volume_report_stats.each do |stat, data|
      volume_report_stats_short[stat] = {}
      data.each { |date, num_emails| volume_report_stats_short[stat][date.strftime($config.volume_report_date_format)] = num_emails }
    end
    
    render :json => volume_report_stats_short
  end

  swagger_api :contacts_report do
    summary 'Return contacts report stats.'

    response :ok
  end
  
  def contacts_report
    sent_label = current_user.gmail_accounts.first.gmail_labels.find_by_label_id('SENT')
    sent_emails_ids = sent_label ? sent_label.emails.pluck(:id) : [-1]
    sent_emails_ids = [-1] if sent_emails_ids.empty?

    contacts_report_stats = {
        :top_senders => current_user.emails.where('"emails"."id" NOT IN (?)', sent_emails_ids).
                                            group(:from_address).order('count_all DESC').limit(10).count,
        :top_recipients => EmailRecipient.where(:email => sent_emails_ids).joins(:person).group(:email_address).
                                          order('count_all DESC').limit(10).count,
        
        :bottom_senders => current_user.emails.where('"emails"."id" NOT IN (?)', sent_emails_ids).
            group(:from_address).order('count_all ASC').limit(10).count,
        :bottom_recipients => EmailRecipient.where(:email => sent_emails_ids).joins(:person).group(:email_address).
            order('count_all ASC').limit(10).count
    }

    render :json => contacts_report_stats
  end

  swagger_api :attachments_report do
    summary 'Return attachments report stats.'

    response :ok
  end
  
  def attachments_report
    content_type_counts = EmailAttachment.where(:email => current_user.emails).group(:content_type).
                                          order('count_all DESC').limit(10).count
    
    if content_type_counts.length > 0
      content_type_sizes = EmailAttachment.where(:email => current_user.emails,
                                                 :content_type => content_type_counts.keys).
                                           group(:content_type).average(:file_size)
    else
      content_type_sizes = {}
    end
    
    content_type_stats = {}
    content_type_counts.each do |content_type, num_attachments|
      content_type_stats[content_type] = {
          :num_attachments => num_attachments,
          :average_file_size => content_type_sizes[content_type].to_i
      }
    end

    attachments_report_stats = {
        :average_file_size => EmailAttachment.where(:email => current_user.emails).average(:file_size).to_i,
        :content_type_stats => content_type_stats
    }

    render :json => attachments_report_stats
  end

  swagger_api :lists_report do
    summary 'Return lists report stats.'

    response :ok
  end
  
  def lists_report
    # average number of emails per day per list
    # average thread length for each list
    # total number of emails per list
    # total number of email threads per list
    
    # percent of emails in each list that are replied to
    # percent of emails that you send that are replied to

    list_report_stats = {}

    list_report_stats[:lists_email_daily_average] =
        current_user.emails.where('list_id IS NOT NULL').group(:list_id).order('daily_average DESC').
                     pluck('list_id, COUNT(*) / GREATEST(1, EXTRACT(day FROM now() - MIN(date))) AS daily_average')

    list_report_stats[:emails_per_list] =
        current_user.emails.where('list_id IS NOT NULL').group(:list_id).order('emails_per_list DESC').
                     pluck('list_id, COUNT(*) AS emails_per_list')
    
    list_report_stats[:email_threads_per_list] = 
        current_user.emails.where('list_id IS NOT NULL').group(:list_id).order('email_threads_per_list DESC').
                     pluck('list_id, COUNT(DISTINCT email_thread_id) AS email_threads_per_list')
    
    list_report_stats[:email_threads_replied_to_per_list] =
        current_user.emails.where('list_id IS NOT NULL').having('COUNT(*) > 1').group(:list_id, :email_thread_id).
                     order('email_threads_replied_to_per_list DESC').
                     pluck('list_id, COUNT(*) AS email_threads_replied_to_per_list')
    
    sent_label = current_user.gmail_accounts.first.gmail_labels.find_by_label_id('SENT')
    if sent_label
      list_report_stats[:sent_emails_per_list] = 
          sent_label.emails.where('list_id IS NOT NULL').group(:list_id).
                     order('sent_emails_per_list DESC').
                     pluck('list_id, COUNT(*) AS sent_emails_per_list')
      
      sent_list_email_message_ids = sent_label.emails.where('list_id IS NOT NULL').pluck(:message_id)

      list_report_stats[:sent_emails_replied_to_per_list] = 
          current_user.emails.joins(:email_in_reply_tos).
                       where('"email_in_reply_tos"."in_reply_to_message_id" IN (?)', sent_list_email_message_ids).
                       group(:list_id).order('sent_emails_replied_to_per_list DESC').
                       pluck('list_id, COUNT(DISTINCT "email_in_reply_tos"."in_reply_to_message_id") AS sent_emails_replied_to_per_list')
    else
      list_report_stats[:sent_emails_per_list] = []
      list_report_stats[:sent_emails_replied_to_per_list] = []
    end

    render :json => list_report_stats
  end

  private

  # Before filters

  def correct_user
    @email = Email.find_by(:email_account => current_user.gmail_accounts.first,
                           :uid => params[:email_uid])

    if @email.nil?
      render :status => $config.http_errors[:email_not_found][:status_code],
             :json => $config.http_errors[:email_not_found][:description]
      return
    end
  end
end
