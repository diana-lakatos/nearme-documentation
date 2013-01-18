class ControlpanelController < ApplicationController
  before_filter :authenticate_user!

  def index
    render 'webapp/launcher', :layout => false
  end
end
