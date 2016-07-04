class Api::BaseController < ApplicationController

  respond_to :json
  before_filter :verified_api_request?
  before_filter :require_authentication # whitelist approach
  skip_before_action :redirect_if_marketplace_password_protected


  rescue_from ::DNM::Error, with: :nm_error
  rescue_from ::DNM::Unauthorized, with: :nm_unauthorized

  private

  # Ensure the user is authenticated
  def require_authentication
    if current_user.nil?
      raise DNM::Unauthorized
    end
  end

  # Return the current user
  def current_user
    if !auth_token.nil?
      @current_user ||= User.find_by(authentication_token: auth_token)
    end
  end

  # Retrieve the current authorization token
  def auth_token
    request.headers['UserAuthorization']
  end

  def verified_api_request?
    if Rails.application.config.verify_api_requests
      valid_csrf_token? || valid_api_token?
    else
      true
    end
  end

  def valid_csrf_token?
    valid_authenticity_token?(session, form_authenticity_param) ||
          valid_authenticity_token?(session, request.headers['X-CSRF-Token'])
  end

  def valid_api_token?
    authenticate_or_request_with_http_token do |token, options|
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

end
