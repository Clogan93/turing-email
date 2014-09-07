class Api::V1::EmailsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_user, :except => [:ip_stats, :volume_report, :top_contacts]

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
    
    received_emails = current_user.emails.where('"emails"."id" NOT IN (?)', sent_label.emails.pluck(:id))
    sent_emails = current_user.emails.where('"emails"."id" IN (?)', sent_label.emails.pluck(:id))

    volume_report_stats = {
      :received_emails_per_month =>
          received_emails.group("DATE_TRUNC('month', date)").order('date_trunc_month_date DESC').limit(6).count,
      :received_emails_per_week =>
          received_emails.group("DATE_TRUNC('week', date)").order('date_trunc_week_date DESC').limit(4).count,
      :received_emails_per_day =>
        received_emails.group("DATE_TRUNC('day', date)").order('date_trunc_day_date DESC').limit(30).count,

      :sent_emails_per_month =>
          sent_emails.group("DATE_TRUNC('month', date)").order('date_trunc_month_date DESC').limit(6).count,
      :sent_emails_per_week =>
        sent_emails.group("DATE_TRUNC('week', date)").order('date_trunc_week_date DESC').limit(4).count,
      :sent_emails_per_day =>
        sent_emails.group("DATE_TRUNC('day', date)").order('date_trunc_day_date DESC').limit(30).count
    }

    volume_report_stats = volume_report_stats.map do |stat, data|
      { stat => data.map { |date, num_emails| { date.rfc2822 => num_emails } } }
    end
    
    render :json => volume_report_stats
  end

  swagger_api :top_contacts do
    summary 'Return top contacts.'

    response :ok
  end
  
  def top_contacts
    sent_label = current_user.gmail_accounts.first.gmail_labels.find_by_label_id('SENT')

    received_emails = current_user.emails.where('"emails"."id" NOT IN (?)', sent_label.emails.pluck(:id))
    sent_emails = current_user.emails.where('"emails"."id" IN (?)', sent_label.emails.pluck(:id))
    
    top_contacts_stats = {
        :top_senders => received_emails.group(:from_address).order('count_all DESC').limit(10).count,
        :top_recipients => EmailRecipient.where(:email => sent_emails).joins(:person).group(:email_address).
                                          order('count_all DESC').limit(10).count
    }

    render :json => top_contacts_stats
  end

  private

  # Before filters

  def correct_user
    @email = Email.find_by(:email_account_type => params[:email_account_type],
                           :email_account_id => params[:email_account_id],
                           :uid => params[:email_id])

    if @email.user != current_user
      render :status => $config.http_errors[:email_not_found][:status_code],
             :json => $config.http_errors[:email_not_found][:description]
      return
    end
  end
end
