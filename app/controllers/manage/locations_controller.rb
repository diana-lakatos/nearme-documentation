class Manage::LocationsController < ApplicationController
  before_filter :authorize_user!

  def index
  end
end
