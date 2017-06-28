# frozen_string_literal: true
class ScheduleRuleForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections

  # @!attribute id
  #   @return [Integer] numeric identifier for the ScheduleRule object
  property :id

  property :_destroy, virtual: true

  # @todo: Is this still used?
  property :time

  # @todo: Is this still used?
  property :date

  # @!attribute run_hours_mode
  #   @return [String] can be 'recurring' or 'specific'; if recurring, the actual schedule times
  #     will occur 'every_hours'; if 'specific', the attribute 'user_times' will be used
  property :run_hours_mode

  # @!attribute every_hours
  #   @return [Integer] used together with run_hours_mode 'recurring'; the actual schedule times
  #     will be every_hours
  property :every_hours

  # @!attribute user_time_start
  #   @return [Time] used together with run_hours_mode 'recurring'; defines the actual start time for the
  #     schedule rule
  property :user_time_start

  # @!attribute user_time_end
  #   @return [Time] used together with run_hours_mode 'recurring'; defines the actual end time for the
  #     schedule rule
  property :user_time_end

  # @!attribute user_times
  #   @return [Array<Time>] used together with run_hours_mode 'specific'; defines the actual times for
  #     the schedule rule
  property :user_times

  # @!attribute run_dates_mode
  #   @return [String] can be 'recurring', 'specific', or 'range'; if 'recurring' the property 'week_days'
  #     will be used to determine the actual schedule rule dates; if 'specific', the user_dates array will be
  #     used to determine the schedule rule dates; if 'range', then user_date_start and user_date_end will be
  #     used to determine the actual schedule rule (range)
  property :run_dates_mode

  # @!attribute week_days
  #   @return [Array<Integer>] used together with run_dates_mode 'recurring'; week_days specify the actual
  #     days of the week in the recurring schedule rule
  property :week_days

  # @!attribute user_dates
  #   @return [Array<Date>] used together with run_dates_mode 'specific'; the dates specified will be the
  #     actual dates of the schedule rule
  property :user_dates

  # @!attribute user_date_start
  #  @return [Date] used together with run_dates_mode 'range'; specifies the actual start date of the schedule
  #    rule
  property :user_date_start

  # @!attribute user_date_end
  #  @return [Date] used together with run_dates_mode 'range'; specifies the actual end date of the schedule
  #    rule
  property :user_date_end
end
