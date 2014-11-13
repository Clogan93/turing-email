class StaticPagesController < ApplicationController
  before_action :signed_in_user, :except => [:home]

  def home
    render layout: "home"
  end

  def mail
  end

end
