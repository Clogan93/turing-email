class Api::V1::EmailAccountsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_email_account

  swagger_controller :email_accounts, 'Email Accounts Controller'

  swagger_api :send_email do
    summary 'Send an email.'

    param :form, :tos, :string, false, 'Array of recipient email addresses'
    param :form, :ccs, :string, false, 'Array of recipient email addresses'
    param :form, :bccs, :string, false, 'Array of recipient email addresses'
    
    param :form, :subject, :string, false, 'Subject'
    param :form, :html_part, :string, false, 'HTML Part'
    param :form, :text_part, :string, false, 'Text Part'

    param :form, :email_in_reply_to_uid, :string, false, 'Email UID being replied to.'

    response :ok
  end

  # TODO write tests
  def send_email
    @email = @email_account.send_email(params[:tos], params[:ccs], params[:bccs],
                                       params[:subject], params[:html_part], params[:text_part],
                                       params[:email_in_reply_to_uid])
    render 'api/v1/emails/show'
  end

  swagger_api :send_email_delayed do
    summary 'Send email delayed.'

    param :form, :sendAtDateTime, :string, false, 'Date to send the email'

    param :form, :tos, :string, false, 'Array of recipient email addresses'
    param :form, :ccs, :string, false, 'Array of recipient email addresses'
    param :form, :bccs, :string, false, 'Array of recipient email addresses'

    param :form, :subject, :string, false, 'Subject'
    param :form, :html_part, :string, false, 'HTML Part'
    param :form, :text_part, :string, false, 'Text Part'

    param :form, :email_in_reply_to_uid, :string, false, 'Email UID being replied to.'

    response :ok
  end

  # TODO write tests
  def send_email_delayed
    @email_account.with_lock do
      delayed_email = DelayedEmail.new
      delayed_email.email_account = @email_account
  
      delayed_email.tos = params[:tos]
      delayed_email.ccs = params[:ccs]
      delayed_email.bccs = params[:bccs]
  
      delayed_email.subject = params[:subject]
  
      delayed_email.html_part = params[:html_part]
      delayed_email.text_part = params[:text_part]
  
      delayed_email.email_in_reply_to_uid = params[:email_in_reply_to_uid]
      
      delayed_email.save!

      delayed_job = delayed_email.delay({:run_at => params[:sendAtDateTime]}, heroku_scale: false).send_and_destroy()
      delayed_email.delayed_job_id = delayed_job.id
      delayed_email.save!
    end

    @email_account.delete_draft(params[:draft_id]) if params[:draft_id]

    render :json => {}
  end

  swagger_api :sync do
    summary 'Queues email sync.'

    response :ok
  end

  # TODO write tests
  def sync
    @email_account.delay.sync_email() if @email_account.last_history_id_synced
    render :json => ''
  end

  swagger_api :search_threads do
    summary 'Search email threads using the same query format as the Gmail search box.'

    param :form, :query, :string, :required, 'Query - same query format as the Gmail search box.'
    param :form, :next_page_token, :string, false, 'Next Page Token - returned in a prior search_threads call.'
    
    response :ok
  end

  # TODO write tests
  def search_threads
    email_thread_uids, @next_page_token = @email_account.search_threads(params[:query], params[:next_page_token])
    @email_threads = EmailThread.where(:uid => email_thread_uids).joins(:emails).includes(:emails).order('"emails"."date" DESC')
  end

  swagger_api :create_draft do
    summary 'Create email draft.'

    param :form, :tos, :string, false, 'Array of recipient email addresses'
    param :form, :ccs, :string, false, 'Array of recipient email addresses'
    param :form, :bccs, :string, false, 'Array of recipient email addresses'

    param :form, :subject, :string, false, 'Subject'
    param :form, :html_part, :string, false, 'HTML Part'
    param :form, :text_part, :string, false, 'Text Part'

    param :form, :email_in_reply_to_uid, :string, false, 'Email UID being replied to.'

    response :ok
  end

  # TODO write tests
  def create_draft
    @email = @email_account.create_draft(params[:tos], params[:ccs], params[:bccs],
                                         params[:subject], params[:html_part], params[:text_part],
                                         params[:email_in_reply_to_uid])
    render 'api/v1/emails/show'
  end

  swagger_api :update_draft do
    summary 'Update email draft.'
    
    param :form, :draft_id, :string, :required, 'Draft ID'

    param :form, :tos, :string, false, 'Array of recipient email addresses'
    param :form, :ccs, :string, false, 'Array of recipient email addresses'
    param :form, :bccs, :string, false, 'Array of recipient email addresses'

    param :form, :subject, :string, false, 'Subject'
    param :form, :html_part, :string, false, 'HTML Part'
    param :form, :text_part, :string, false, 'Text Part'

    response :ok
  end

  # TODO write tests
  def update_draft
    @email = @email_account.update_draft(params[:draft_id],
                                         params[:tos], params[:ccs], params[:bccs],
                                         params[:subject], params[:html_part], params[:text_part])
    render 'api/v1/emails/show'
  end

  swagger_api :send_draft do
    summary 'Send email draft.'

    param :form, :draft_id, :string, :required, 'Draft ID'

    response :ok
  end

  # TODO write tests
  def send_draft
    @email = @email_account.send_draft(params[:draft_id])

    render 'api/v1/emails/show'
  end

  swagger_api :delete_draft do
    summary 'Delete email draft.'

    param :form, :draft_id, :string, :required, 'Draft ID'

    response :ok
  end

  # TODO write tests
  def delete_draft
    @email_account.delete_draft(params[:draft_id])

    render :json => {}
  end
end
