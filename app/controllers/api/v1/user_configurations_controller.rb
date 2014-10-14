class Api::V1::UserConfigurationsController < ApiController
  before_action {  signed_in_user(true) }

  swagger_controller :users, 'User Configurations Controller'

  swagger_api :show do
    summary 'Return the user configuration.'

    response :ok
  end

  def show
    @user_configuration = current_user.user_configuration
  end

  swagger_api :update do
    summary 'Update the user configuration.'
    
    param :form, :genie_enabled, :boolean, :description => 'Genie Enabled status'
    param :form, :split_pane_mode, :string, false, 'Split Pane Mode (off, horizontal, or vertical)'

    response :ok
  end
  
  def update
    @user_configuration = current_user.user_configuration
    permitted_params = params.permit(:genie_enabled, :split_pane_mode, :keyboard_shortcuts_enabled)
    @user_configuration.update_attributes!(permitted_params)
    
    render 'api/v1/user_configurations/show'
  end
end