class Api::V1::ListSubscriptionsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_email_account

  swagger_controller :list_subscriptions, 'List Subscriptions Controller'

  swagger_api :index do
    summary 'Return list subscriptions.'

    response :ok
  end
  
  def index
    @list_subscriptions = @email_account.list_subscriptions.select(:list_id, :list_name, :list_domain).order(:list_name).uniq
  end
end
