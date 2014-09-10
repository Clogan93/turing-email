class StaticPagesController < ApplicationController
  before_action :signed_in_user, :except => [:home]

  def home
  end

  def mail
  end
end
