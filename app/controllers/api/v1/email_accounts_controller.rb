class Api::V1::EmailAccountsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_email_account

  swagger_controller :email_accounts, 'Email Accounts Controller'

  swagger_api :send_email do
    summary 'Send an email.'

    param :form, :tos, :string, 'Array of recipient email addresses'
    param :form, :ccs, :string, 'Array of recipient email addresses'
    param :form, :bccs, :string, 'Array of recipient email addresses'
    
    param :form, :subject, :string, 'Subject'
    param :form, :email_body, :string, 'Body'

    param :form, :email_in_reply_to_uid, :string, 'Email UID being replied to.'

    response :ok
  end

  # TODO write tests
  def send_email
    @email_account.send_email(params[:tos], params[:ccs], params[:bccs],
                              params[:subject], params[:email_body],
                              params[:email_in_reply_to_uid])
    render :json => {}
  end

  swagger_api :sync do
    summary 'Sync email. Returns true if any emails were synced, else false.'

    response :ok
  end

  # TODO write tests
  def sync
    synced_emails = @email_account.sync_email()
    
    render :json => {:synced_emails => synced_emails}
  end

  swagger_api :search_threads do
    summary 'Search email threads using the same query format as the Gmail search box.'

    param :form, :query, :string, :required, 'Query - same query format as the Gmail search box.'
    param :form, :next_page_token, :string, 'Next Page Token - returned in a prior search_threads call.'
    
    response :ok
  end

  # TODO write tests
  def search_threads
    email_thread_uids, @next_page_token = @email_account.search_threads(params[:query], params[:next_page_token])
    @email_threads = EmailThread.where(:uid => email_thread_uids).joins(:emails).includes(:emails).order('"emails"."date" DESC')
  end
  
  swagger_api :get_draft_ids do
    summary 'Return email draft IDs.'

    response :ok
  end

  # TODO write tests
  def get_draft_ids
    render :json => @email_account.get_draft_ids()
  end

  swagger_api :create_draft do
    summary 'Create email draft.'

    param :form, :tos, :string, 'Array of recipient email addresses'
    param :form, :ccs, :string, 'Array of recipient email addresses'
    param :form, :bccs, :string, 'Array of recipient email addresses'

    param :form, :subject, :string, 'Subject'
    param :form, :email_body, :string, 'Body'

    param :form, :email_in_reply_to_uid, :string, 'Email UID being replied to.'

    response :ok
  end

  def create_draft
    email_draft_uid = @email_account.create_draft(params[:tos], params[:ccs], params[:bccs],
                                                  params[:subject], params[:email_body],
                                                  params[:email_in_reply_to_uid])
    render :json => {:email_draft_uid => email_draft_uid}
  end

  swagger_api :update_draft do
    summary 'Update email draft.'
    
    param :form, :draft_id, :string, :required, 'Draft ID'

    param :form, :tos, :string, 'Array of recipient email addresses'
    param :form, :ccs, :string, 'Array of recipient email addresses'
    param :form, :bccs, :string, 'Array of recipient email addresses'

    param :form, :email_in_reply_to_uid, :string, 'Email UID being replied to.'

    param :form, :subject, :string, 'Subject'
    param :form, :email_body, :string, 'Body'

    response :ok
  end

  # TODO write tests
  def update_draft
    @email_account.update_draft(params[:draft_id],
                                params[:tos], params[:ccs], params[:bccs],
                                params[:subject], params[:email_body],
                                params[:email_in_reply_to_uid])
    render :json => {}
  end

  swagger_api :send_draft do
    summary 'Send email draft.'

    param :form, :draft_id, :string, :required, 'Draft ID'

    response :ok
  end

  # TODO write tests
  def send_draft
    @email_account.send_draft(params[:draft_id])
    render :json => {}
  end
end
