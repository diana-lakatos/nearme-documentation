class ScheduleExceptionRuleDrop < BaseDrop
  
  # @return [ScheduleExceptionRuleDrop]
  attr_reader :schedule_exception_rule

  # @!method label
  #   Label for the exception rule
  #   @return (see ScheduleExceptionRule#label)
  # @!method duration_range_start
  #   Start time of the duration
  #   @return (see ScheduleExceptionRule#duration_range_start)
  # @!method duration_range_end
  #   End time of the duration
  #   @return (see ScheduleExceptionRule#duration_range_end)
  delegate :label, :duration_range_start, :duration_range_end, to: :schedule_exception_rule

  def initialize(schedule_exception_rule)
    @schedule_exception_rule = schedule_exception_rule
  end

  # @return [String] formatted representation of the duration range
  def period
    "#{I18n.l(duration_range_start.to_date, format: :short)} - #{I18n.l(duration_range_end.to_date, format: :short)}"
  end
end
