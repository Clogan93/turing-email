class Api::V1::EmailRulesController < ApiController
  before_action { signed_in_user(true) }

  swagger_controller :users, 'Email Rules Controller'

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

    GenieRule.find_or_create_by(:user => current_user,
                                :from_address => from_address, :to_address => to_address,
                                :subject => subject, :list_id => list_id,
                                :destination_folder => destination_folder)
    render :json => ''
  end
  
  swagger_api :recommended_rules do
    summary 'Return recommended rules.'

    response :ok
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
end
