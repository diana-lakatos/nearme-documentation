# frozen_string_literal: true
class ScheduleExceptionRuleDrop < BaseDrop
  # @return [ScheduleExceptionRuleDrop]
  attr_reader :schedule_exception_rule

  # @!method label
  #   @return [String] Label for the exception rule
  # @!method duration_range_start
  #   @return [DateTime] Start time of the duration
  # @!method duration_range_end
  #   @return [DateTime] End time of the duration
  delegate :label, :duration_range_start, :duration_range_end, to: :schedule_exception_rule

  def initialize(schedule_exception_rule)
    @schedule_exception_rule = schedule_exception_rule
  end

  # @return [String] formatted representation of the duration range
  # @todo -- deprecate - user formatting
  def period
    "#{I18n.l(duration_range_start.to_date, format: :short)} - #{I18n.l(duration_range_end.to_date, format: :short)}"
  end
end
