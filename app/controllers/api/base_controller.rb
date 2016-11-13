# frozen_string_literal: true
class Api::BaseController < ActionController::Base
  force_ssl if: -> { Rails.application.config.use_only_ssl }

  respond_to :json

  around_action :set_time_zone

  before_action :set_i18n_locale
  before_action :set_raygun_custom_data

  before_action :verified_api_request?
  before_action :require_authentication # whitelist approach
  before_action :require_authorization # some actions only by MPO or token
  before_action :set_paper_trail_whodunnit

  rescue_from ::DNM::Error, with: :nm_error
  rescue_from ::DNM::Unauthorized, with: :nm_unauthorized

  private

  # Ensure the user is authenticated
  def require_authentication
    raise DNM::Unauthorized unless current_user
  end

  def require_authorization
    return true if verified_api_request? || valid_api_token? # we assume api token is secret
    current_user.instance_admins.exists? # for now no role distinguish - we assume MPO won't be hacking :)
  end

  # Return the current user
  def current_user
    if auth_token.present?
      @current_user ||= User.find_by(authentication_token: auth_token)
    else
      super
    end
  end

  # Retrieve the current authorization token
  def auth_token
    request.headers['UserAuthorization'].presence
  end

  def verified_api_request?
    skip_api_requests_verification? || valid_csrf_token? || valid_api_token?
  end

  def skip_api_requests_verification?
    !Rails.application.config.verify_api_requests
  end

  def valid_csrf_token?
    valid_authenticity_token?(session, form_authenticity_param) ||
      valid_authenticity_token?(session, request.headers['X-CSRF-Token'])
  end

  def valid_api_token?
    authenticate_or_request_with_http_token do |token, _options|
      current_instance.api_keys.active.exists?(token: token)
    end
  end

  # Render an error message
  def nm_error(e)
    render json: e.to_hash, status: e.status
  end

  # Render an unauthorized message
  def nm_unauthorized(e)
    render json: { message: e.message }, status: 401
  end

  def set_i18n_locale
    I18n.locale = language_service.get_language
    session[:language] = I18n.locale
  end

  def set_raygun_custom_data
    return if Rails.application.config.silence_raygun_notification
    begin
      Raygun.configuration.custom_data = {
        platform_context: platform_context.to_h,
        request_params: params.reject { |k, _v| Rails.application.config.filter_parameters.include?(k.to_sym) },
        current_user_id: current_user.try(:id),
        process_pid: Process.pid,
        process_ppid: Process.ppid,
        git_version: Rails.application.config.git_version
      }
    rescue => e
      Rails.logger.debug "Error when preparing Raygun custom_params: #{e}"
    end
  end

  def set_time_zone(&block)
    time_zone = current_user.try(:time_zone).presence || current_instance.try(:time_zone).presence || 'UTC'
    Time.use_zone(time_zone, &block)
  end

  def language_service
    @language_service ||= Language::LanguageService.new(
      language_params,
      fallback_languages,
      current_instance.available_locales
    )
  end

  def language_params
    [params[:language]]
  end

  def fallback_languages
    [
      session[:language],
      current_user.try(:language),
      current_instance.try(:primary_locale),
      I18n.default_locale
    ]
  end

  def current_instance
    PlatformContext.current.instance
  end

  def secured_params
    @secured_params ||= SecuredParams.new
  end
end
