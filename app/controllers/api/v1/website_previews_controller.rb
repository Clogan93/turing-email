require 'open-uri'

class Api::V1::WebsitePreviewsController < ApiController
  before_action {  signed_in_user(true) }

  swagger_controller :website_previews, 'Website Previews'

  swagger_api :proxy do
    summary 'Proxies a URL.'

    param :form, :url, :string, :required, 'URL'
    
    response :ok
  end

  def proxy
    url = params[:url]
    url += "http://" if url !~ /https?:\/\//i
    html = open(url).read
    render :html => html.html_safe
  end
end
