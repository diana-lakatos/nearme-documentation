class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :show_coming_soon, :if => Proc.new { Rails.env.production? }

  private

    def show_coming_soon
      render :template => "coming_soon/index", :layout => false if !session[:disable_coming_soon]
    end

end
