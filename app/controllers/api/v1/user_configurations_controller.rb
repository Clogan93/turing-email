class Api::V1::UserConfigurationsController < ApiController
  before_action {  signed_in_user(true) }

  swagger_controller :users, 'User Configurations Controller'

  swagger_api :show do
    summary 'Return the user configuration.'

    response :ok
  end

  # TODO write tests
  def show
    @user_configuration = current_user.user_configuration
  end

  swagger_api :update do
    summary 'Update the user configuration.'
    
    param :form, :genie_enabled, :boolean, :description => 'Genie Enabled status'
    param :form, :split_pane_mode, :string, false, 'Split Pane Mode (off, horizontal, or vertical)'

    response :ok
  end
  
  # TODO write tests
  def update
    @user_configuration = current_user.user_configuration
    
    @user_configuration.genie_enabled = params[:genie_enabled] if params[:genie_enabled]
    @user_configuration.split_pane_mode = params[:split_pane_mode] if params[:split_pane_mode]
    @user_configuration.save!
    
    render 'api/v1/user_configurations/show'
  end
end