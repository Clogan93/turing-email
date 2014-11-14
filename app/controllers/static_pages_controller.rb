class StaticPagesController < ApplicationController
  before_action :signed_in_user, :except => [:home]

  def home
    if current_user
      redirect_to mail_url
      return
    end
    
    render layout: "home"
  end

  def mail
  end

end
