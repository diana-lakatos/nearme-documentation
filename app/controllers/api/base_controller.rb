# frozen_string_literal: true
require 'application_responder'
module Api
  class BaseController < ActionController::Base
    self.responder = ApplicationResponder
    force_ssl if: -> { Rails.application.config.use_only_ssl }
    include ViewsFromDb
    include RaygunExceptions

    JSONAPI_CONTENT_TYPE = 'application/vnd.api+json'

    layout :layout_for_request_type

    respond_to :json, :html

    around_action :set_time_zone

    before_action :verified_api_request?
    before_action :require_authentication # whitelist approach
    before_action :require_authorization # some actions only by MPO or token
    before_action :set_paper_trail_whodunnit
    before_action :set_content_type, if: -> { request.format.symbol == :js || request.format.symbol == :json }

    rescue_from ::DNM::Error, with: :nm_error
    rescue_from ::DNM::Unauthorized, with: :nm_unauthorized
    rescue_from Authorize::UnauthorizedAction do |error|
      HandleUnauthorizedError.new(controller: self, error: error).run
    end

    # Return the current user
    def current_user
      if auth_token.present?
        @current_user ||= User.find_by(authentication_token: auth_token)
      else
        super
      end
    end

    protected

    def layout_for_request_type
      if request.xhr?
        false
      else
        layout_name
      end
    end

    def layout_name
      PlatformContext.current.instance.is_community? ? 'community' : 'application'
    end

    def redirect_unverified_user
      unless (current_user&.verified_at.present? && current_user&.expires_at.try(:>, Time.zone.now)) || current_user&.admin? || current_user&.instance_admin?
        flash[:warning] = t('flash_messages.need_verification_html')
        redirect_to root_path
      end
    end

    def render_api_object(object, options = {})
      render json: ApiSerializer.serialize_object(object, options)
    end

    def render_api_collection(collection, options = {})
      render json: ApiSerializer.serialize_collection(collection, options)
    end

    def render_api_errors(errors, status = 409)
      render json: ApiSerializer.serialize_errors(errors), status: status
    end

    # Ensure the user is authenticated
    def require_authentication
      raise DNM::Unauthorized unless current_user
    end

    def require_authorization
      return true if verified_api_request? || valid_api_token? # we assume api token is secret
      current_user.instance_admin? # for now no role distinguish - we assume MPO won't be hacking :)
    end

    # Retrieve the current authorization token
    def auth_token
      request.headers['UserAuthorization'].presence
    end

    def verified_api_request?
      skip_api_requests_verification? || verified_request? || valid_api_token?
    end

    def skip_api_requests_verification?
      !Rails.application.config.verify_api_requests
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
      render json: { meta: { message: e.message } }, status: 401
    end

    def set_content_type
      response.headers['Content-Type'] = JSONAPI_CONTENT_TYPE
    end

    def set_time_zone(&block)
      time_zone = current_user.try(:time_zone).presence || current_instance.try(:time_zone).presence || 'UTC'
      Time.use_zone(time_zone, &block)
    end

    def current_instance
      PlatformContext.current.instance
    end

    def secured_params
      @secured_params ||= SecuredParams.new
    end
  end
end
