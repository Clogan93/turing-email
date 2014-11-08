class Api::V1::PeopleController < ApiController
  before_action { signed_in_user(true) }

  swagger_controller :people, 'People Controller'

  swagger_api :recent_threads do
    summary 'Return 10 most recent threads.'

    param :form, :email, :string, false, 'Email'
    
    response :ok
  end
  
  def recent_thread_subjects
    email = params[:email]
    
    gmail_account = current_user.gmail_accounts.first
    recent_thread_subjects = gmail_account.recent_thread_subjects(email)
    
    render :json => recent_thread_subjects
  end
end
