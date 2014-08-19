class StaticPagesController < ApplicationController
  def home
  end

  def inbox
  end

  def email_threading_prototype
  end
  
  def api_docs
    render 'swagger_ui/_swagger_ui', :locals => {:discovery_url => '/api-docs/api-docs.json'}
  end

end
