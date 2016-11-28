# frozen_string_literal: true
class CustomModelTypeDrop < BaseDrop
  # @!method name
  #   @return [String] name of the custom model type as a string
  delegate :name, to: :source

  def initialize(source)
    @source = source
  end
end
