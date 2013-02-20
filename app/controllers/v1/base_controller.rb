require "dnm_errors"

class V1::BaseController < ApplicationController

  respond_to :json

  # Error handling here...
  unless Rails.application.config.consider_all_requests_local

    rescue_from ::DNM::Error, with: :dnm_error
    rescue_from ::DNM::Unauthorized, with: :dnm_unauthorized

  end

  private

  # Parse the request body from JSON
  def json_params

    @json_params ||= ActiveSupport::JSON.decode(request.body)

  rescue MultiJson::DecodeError
    raise DNM::InvalidJSON

  end

  # Ensure the user is authenticated
  def require_authentication
    if current_user.nil?
      render json: { message: "Invalid Authentication" }, status: 401
    end
  end

  # Return the current user
  def current_user
    if !auth_token.nil?
      @current_user ||= User.find_by_authentication_token(auth_token)
    end
  end

  # Retrieve the current authorization token
  def auth_token
    request.headers['Authorization'] || params[:token]
  end

  # Render an error message
  def dnm_error(e)
    render json: e.to_hash, status: e.status
  end

  # Render an unauthorized message
  def dnm_unauthorized(e)
    render json: { message: e.message }, status: 401
  end

end
