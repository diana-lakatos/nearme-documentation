# frozen_string_literal: true
class CustomModelTypeDrop < BaseDrop
  # @!method name
  #   @return (see CustomModelType#name)
  delegate :name, to: :source

  def initialize(source)
    @source = source
  end
end
