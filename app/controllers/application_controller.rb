class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :show_coming_soon

  private

    def show_coming_soon
      render :template => "coming_soon/index" if !session[:disable_coming_soon]
    end

end
