class StaticPagesController < ApplicationController
  before_action :signed_in_user, :except => [:home]

  def home
  end

  def home2
    render layout: "home"
  end

  def mail
  end
end
