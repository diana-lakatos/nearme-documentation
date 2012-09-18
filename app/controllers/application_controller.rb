class ApplicationController < ActionController::Base

  protect_from_forgery
  layout "new_layout"

  before_filter :set_tabs

  private

    def set_tabs
    end

end
