# frozen_string_literal: true
class FormConfigurationDrop < BaseDrop
  # @!method id
  #   @return [Integer] numeric identifier of the user object
  delegate :id, to: :source
end
