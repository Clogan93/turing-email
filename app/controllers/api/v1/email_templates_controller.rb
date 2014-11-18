class Api::V1::EmailTemplatesController < ApiController
  before_action { signed_in_user(true) }
  
  before_action :correct_user, :except => [:create, :index]

  swagger_controller :email_templates, 'Email Templates Controller'

  swagger_api :create do
    summary 'Create an email template.'

    param :form, :name, :string, :required, 'Name'
    param :form, :text, :string, :optional, 'Text'
    param :form, :html, :string, :optional, 'HTML'

    response :ok
  end
  
  def create
    begin
      @email_template = EmailTemplate.create!(:user => current_user, :name => params[:name],
                                              :text => params[:text], :html => params[:html])
    rescue ActiveRecord::RecordNotUnique
      render :status => $config.http_errors[:email_template_name_in_use][:status_code],
             :json => $config.http_errors[:email_template_name_in_use][:description]
      return
    end
    
    render 'api/v1/email_templates/show'
  end

  swagger_api :index do
    summary 'Return existing email templates.'

    response :ok
  end
  
  def index
    @email_templates = current_user.email_templates
  end

  swagger_api :update do
    summary 'Update email template.'

    param :form, :email_template_uid, :string, :required, 'Email Template UID'
    param :form, :name, :string, :optional, 'Name'
    param :form, :text, :string, :optional, 'Text'
    param :form, :html, :string, :optional, 'HTML'

    response :ok
  end

  def update
    begin
      permitted_params = params.permit(:name, :text, :html)
      @email_template.update_attributes!(permitted_params)
    rescue ActiveRecord::RecordNotUnique
      render :status => $config.http_errors[:email_template_name_in_use][:status_code],
             :json => $config.http_errors[:email_template_name_in_use][:description]
      return
    end

    render 'api/v1/email_templates/show'
  end
  
  swagger_api :destroy do
    summary 'Delete email template.'

    param :path, :email_template_uid, :string, :required, 'Email Template UID'
    
    response :ok
  end
  
  def destroy
    @email_template.destroy!

    render :json => {}
  end
  
  private

  # Before filters

  def correct_user
    @email_template = EmailTemplate.find_by(:user => current_user, :uid => params[:email_template_uid])

    if @email_template.nil?
      render :status => $config.http_errors[:email_template_not_found][:status_code],
             :json => $config.http_errors[:email_template_not_found][:description]
      return
    end
  end
end
