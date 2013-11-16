class ErrorsController < ApplicationController

  skip_before_filter :redirect_if_domain_not_valid
  before_filter :get_status_code
  layout 'errors'

  def not_found
    error = session[:not_found]
    error_type = error.try(:keys).try(:first)
    begin
      case error_type
      when :instance_page_not_found
        @path = error[error_type]
        render :template => 'errors/instance_page_not_found', :status => 404, :formats => [:html]
      when :manage_listing_no_permission, :manage_location_no_permission
        @object_name = (error_type == :manage_listing_no_permission ? 'listing' : 'location' )
        render :template => 'errors/manage_listing_or_location_no_permission', :status => 404, :formats => [:html]
      when nil
        render :template => 'errors/not_found', :status => 404, :formats => [:html]
      end
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
