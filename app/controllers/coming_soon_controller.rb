class ComingSoonController < ApplicationController

  skip_before_filter :show_coming_soon

  def start
    session[:disable_coming_soon] = false
    redirect_to :root
  end

  def stop
    session[:disable_coming_soon] = true
    redirect_to :root
  end

end
