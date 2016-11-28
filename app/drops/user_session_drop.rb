# frozen_string_literal: true
class UserSessionDrop < BaseDrop
  # @!method email
  #   Email used to authenticate
  # @return [String] path to this user message in the app
  # @!method password
  #   Password used to authenticate
  # @return [String] path to this user message in the app
  delegate :email, :password, to: :source
end
