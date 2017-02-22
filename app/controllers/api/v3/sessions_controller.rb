# frozen_string_literal: true
module Api
  class V3::SessionsController < BaseController
    skip_before_action :require_authentication, only: [:create]
    skip_before_action :require_authorization

    def create
      user = User.find_by(email: params['email'])

      if user && user.valid_password?(params['password'])
        user.ensure_authentication_token!
        sign_in(user)
        render json: ApiSerializer.serialize_object(OpenStruct.new(type: 'user', id: user.id, token: user.reload.authentication_token, jsonapi_serializer_class_name: 'SessionJsonSerializer'))
      else
        user ||= User.new
        user.errors.add(:password, t('devise.failure.invalid'))
        user.errors.add(:email, t('devise.failure.invalid'))
        render json: ApiSerializer.serialize_errors(user.errors), status: :unauthorized
      end
    end
  end
end
