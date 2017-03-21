# frozen_string_literal: true
class UserSession
  delegate :email, :password, :model_name, :to_key, :to_model, to: :user
  def initialize(params)
    @params = params
    @user = User.new
  end

  def create
    @user = User.find_by(email: @params['email'])
    if user.valid_password?(@params['password'])
      user.ensure_authentication_token!
      true
    else
      add_errors
      false
    end
  end

  def user
    @user ||= User.new
  end

  def errors
    @user.errors
  end

  def to_json(*_args)
    ApiSerializer.serialize_object(
      OpenStruct.new(type: 'user',
                     id: @user.id,
                     token: @user.reload.authentication_token,
                     jsonapi_serializer_class_name: 'SessionJsonSerializer')
    )
  end

  def to_liquid
    UserSessionDrop.new(self)
  end

  protected

  def add_errors
    user.errors.add(:password, I18n.t('devise.failure.invalid'))
    user.errors.add(:email, I18n.t('devise.failure.invalid'))
  end
end
