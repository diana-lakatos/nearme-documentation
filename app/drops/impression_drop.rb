# frozen_string_literal: true
class ImpressionDrop < BaseDrop
  # @return [Object]
  attr_reader :impression_object

  # @!method impressionable
  #   @return [Object] object for which this impression has been recorded
  #     (e.g. Location, Transactable etc.)
  delegate :impressionable, to: :impression_object

  def initialize(impression_object)
    @impression_object = impression_object
  end
end
