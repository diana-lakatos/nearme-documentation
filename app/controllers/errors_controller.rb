class ErrorsController < ApplicationController

  layout 'errors'

  def not_found
    begin
      render :template => 'errors/not_found', :status => 404, :formats => [:html]
    rescue
      server_error
    end
  end

  def server_error
    render file: "#{Rails.root}/public/500.html", layout: false, status: 500
  end

end
