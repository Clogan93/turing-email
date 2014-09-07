class Api::V1::EmailsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_user, :except => [:ip_stats, :volume_report, :top_contacts, :attachments_report]

  swagger_controller :emails, 'Emails Controller'

  swagger_api :show do
    summary 'Return email.'

    param :path, :email_account_type, :string, :required, 'Email Account Type'
    param :path, :email_account_id, :string, :required, 'Email Account ID'
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
      data.each { |date, num_emails| volume_report_stats_short[stat][date.strftime('%-m/%-d/%Y')] = num_emails }
    end
    
    render :json => volume_report_stats_short
  end

  swagger_api :top_contacts do
    summary 'Return top contacts.'

    response :ok
  end
  
  def top_contacts
    sent_label = current_user.gmail_accounts.first.gmail_labels.find_by_label_id('SENT')
    sent_emails_ids = sent_label ? sent_label.emails.pluck(:id) : [-1]

    top_contacts_stats = {
        :top_senders => current_user.emails.where('"emails"."id" NOT IN (?)', sent_emails_ids).
                                            group(:from_address).order('count_all DESC').limit(10).count,
        :top_recipients => EmailRecipient.where(:email => sent_emails_ids).joins(:person).group(:email_address).
                                          order('count_all DESC').limit(10).count
    }

    render :json => top_contacts_stats
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

  private

  # Before filters

  def correct_user
    @email = Email.find_by(:email_account_type => params[:email_account_type],
                           :email_account_id => params[:email_account_id],
                           :uid => params[:email_id])

    if @email.nil? || @email.user != current_user
      render :status => $config.http_errors[:email_not_found][:status_code],
             :json => $config.http_errors[:email_not_found][:description]
      return
    end
  end
end
