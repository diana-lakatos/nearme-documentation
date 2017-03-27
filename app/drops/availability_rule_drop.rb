# frozen_string_literal: true
class AvailabilityRuleDrop < BaseDrop

  # @!method id
  #   @return [Integer] returns id of object
  # @!method open_time_with_default
  #   @return [String] returns open time with default value of "12:00"
  # @!method close_time_with_default
  #   @return [String] returns close time with default of "23:59"
  delegate :id, :open_time_with_default, :close_time_with_default, to: :source

end
