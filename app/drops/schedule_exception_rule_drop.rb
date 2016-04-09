class ScheduleExceptionRuleDrop < BaseDrop

  attr_reader :schedule_exception_rule

  delegate :label, :duration_range_start, :duration_range_end, to: :schedule_exception_rule

  def initialize(schedule_exception_rule)
    @schedule_exception_rule = schedule_exception_rule
  end

  def period
    "#{I18n.l(duration_range_start.to_date, format: :short)} - #{I18n.l(duration_range_end.to_date, format: :short)}"
  end

end

