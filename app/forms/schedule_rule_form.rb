# frozen_string_literal: true
class ScheduleRuleForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  property :id
  property :_destroy, virtual: true

  property :time
  property :date
  property :run_hours_mode
  property :every_hours
  property :user_time_start
  property :user_time_end
  property :user_times
  property :run_dates_mode
  property :week_days
  property :user_dates
  property :user_date_start
  property :user_date_end
end
