# frozen_string_literal: true
class ImpressionDrop < BaseDrop
  # @return [Address]
  attr_reader :impression_object

  # @!method street
  #   returns the street as a string
  #   @return (see Address#street)

  delegate :impressionable, to: :impression_object

  def initialize(impression_object)
    @impression_object = impression_object
  end
end
