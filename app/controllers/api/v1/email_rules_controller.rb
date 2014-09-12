class Api::V1::EmailRulesController < ApiController
  before_action { signed_in_user(true) }
  
  before_action :correct_user, :except => [:create, :index, :recommended_rules]

  swagger_controller :email_rules, 'Email Rules Controller'

  swagger_api :create do
    summary 'Create an email rule.'

    param :form, :from_address, :string, 'From Address'
    param :form, :to_address, :string, 'To Adddress'
    param :form, :subject, :string, 'Subject'
    param :form, :list_id, :string, 'List ID'

    param :form, :destination_folder, :string, 'Destination Folder'

    response :ok
  end
  
  def create
    from_address = params[:from_address].blank? ? nil : params[:from_address]
    to_address = params[:to_address].blank? ? nil : params[:to_address]
    subject = params[:subject].blank? ? nil : params[:subject]
    list_id = params[:list_id].blank? ? nil : params[:list_id]
    
    destination_folder = params[:destination_folder].blank? ? nil : params[:destination_folder]

    begin
      EmailRule.find_or_create_by!(:user => current_user,
                                   :from_address => from_address, :to_address => to_address,
                                   :subject => subject, :list_id => list_id,
                                   :destination_folder => destination_folder)
    rescue ActiveRecord::RecordNotUnique
    end
    
    render :json => ''
  end

  swagger_api :index do
    summary 'Return existing email rules.'

    response :ok
  end
  
  def index
    @email_rules = current_user.email_rules
  end
  
  swagger_api :recommended_rules do
    summary 'Return recommended rules.'

    response :ok
  end

  swagger_api :destroy do
    summary 'Delete email rule.'

    param :path, :email_rule_uid, :string, :required, 'Email Rule UID'
    
    response :ok
  end
  
  def destroy
    @email_rule.destroy!

    render :json => ''
  end

  def recommended_rules
    lists_email_daily_average = Email.lists_email_daily_average(current_user, where: ['auto_filed=?', true])
    
    rules_recommended = []
    
    lists_email_daily_average.each do |list_name, list_id, average|
      break if average < $config.recommended_rules_average_daily_list_volume
      next if current_user.email_rules.where(:list_id => list_id).count > 0

      subfolder = list_name
      subfolder = list_id if subfolder.nil?
      
      rules_recommended << { :list_id => list_id, :destination_folder => "List Emails/#{subfolder}" }
    end

    render :json => rules_recommended
  end
  
  private

  # Before filters

  def correct_user
    @email_rule = EmailRule.find_by(:user => current_user,
                                    :uid => params[:email_rule_uid])

    if @email_rule.nil?
      render :status => $config.http_errors[:email_rule_not_found][:status_code],
             :json => $config.http_errors[:email_rule_not_found][:description]
      return
    end
  end
end
