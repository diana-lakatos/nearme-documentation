class ErrorsController < ApplicationController

  skip_before_filter :redirect_if_domain_not_configured
  before_filter :get_status_code
  layout 'errors'

  def not_found
    begin
      render :template => 'errors/not_found', :status => 404, :formats => [:html]
    rescue
      server_error
    end
  end

  def server_error
    begin
      render :template => 'errors/server_error', :status => @status_code, :formats => [:html]
    rescue
      # just in case things are so bad that we cannot display anything at all
      render file: "#{Rails.root}/public/500.html", layout: false, status: @status_code
    end
  end

  def domain_not_configured
    render :template => 'errors/domain_not_configured', :status => 404, :formats => [:html]
  end

  private

  def get_status_code
    @status_code = ActionDispatch::ExceptionWrapper.new(env, env["action_dispatch.exception"]).status_code
  end
end
