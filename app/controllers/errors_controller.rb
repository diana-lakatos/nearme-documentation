class ErrorsController < ApplicationController
  skip_before_filter :set_locale
  skip_before_filter :redirect_if_marketplace_password_protected
  skip_before_filter :redirect_if_domain_not_valid
  before_filter :find_exception
  layout 'errors'

  def not_found
    case env['action_dispatch.exception'].class.name
    when 'Page::NotFound'
      render template: 'errors/instance_page_not_found', status: 404, formats: [:html]
    when 'Transactable::NotFound'
      @object_name = 'listing'
      render template: 'errors/manage_listing_or_location_no_permission', status: 404, formats: [:html]
    when 'Location::NotFound'
      @object_name = 'location'
      render template: 'errors/manage_listing_or_location_no_permission', status: 404, formats: [:html]
    else
      render template: 'errors/not_found', status: 404, formats: [:html]
    end
  rescue StandardError => e
    Rails.logger.error "error while rendering not found: #{e}"
    server_error
  end

  def server_error
    render template: 'errors/server_error', status: @status_code, formats: [:html]
  rescue
    # just in case things are so bad that we cannot display anything at all
    render file: "#{Rails.root}/public/500.html", layout: false, status: @status_code
  end

  private

  def find_exception
    @status_code = ActionDispatch::ExceptionWrapper.new(env, env['action_dispatch.exception']).status_code
  end
end
