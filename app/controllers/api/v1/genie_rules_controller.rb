class Api::V1::GenieRulesController < ApiController
  before_action do
    signed_in_user(true)
  end

  swagger_controller :genie_rules, 'Genie Rules Controller'

  swagger_api :create do
    summary 'Create a genie rule.'

    param :form, :from_address, :string, 'From Address'
    param :form, :to_address, :string, 'To Adddress'
    param :form, :subject, :string, 'Subject'
    param :form, :list_id, :string, 'List ID'

    response :ok
  end

  def create
    from_address = params[:from_address].blank? ? nil : params[:from_address]
    to_address = params[:to_address].blank? ? nil : params[:to_address]
    subject = params[:subject].blank? ? nil : params[:subject]
    list_id = params[:list_id].blank? ? nil : params[:list_id]
    
    GenieRule.find_or_create_by(:user => current_user,
                                :from_address => from_address, :to_address => to_address,
                                :subject => subject, :list_id => list_id)
    render :json => ''
  end

  swagger_api :index do
    summary 'Return existing genie rules.'

    response :ok
  end

  def index
    @genie_rules = current_user.genie_rules
  end
end
