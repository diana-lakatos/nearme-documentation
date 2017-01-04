class ErrorsController < ApplicationController
  skip_before_filter :set_locale
  skip_before_filter :redirect_if_marketplace_password_protected
  skip_before_filter :redirect_if_domain_not_valid
  before_filter :find_exception
  layout 'errors'

  def not_found
    render template: 'errors/not_found', status: 404, formats: [:html]
  rescue StandardError => e
    Rails.logger.error "error while rendering not found: #{e}"
    server_error
  end

  def server_error
    render template: 'errors/server_error', status: @status_code, formats: [:html]
  end

  private

  def find_exception
    @status_code = ActionDispatch::ExceptionWrapper.new(env, env['action_dispatch.exception']).status_code
  end
end
