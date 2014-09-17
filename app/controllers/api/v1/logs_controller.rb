class Api::V1::LogsController < ApiController
  swagger_controller :logs, 'Logs Controller'

  swagger_api :log do
    summary 'Log message.'

    response :ok
  end
  
  def log
    render :json => {}
  end
end
