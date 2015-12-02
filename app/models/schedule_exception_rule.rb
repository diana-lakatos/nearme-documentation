class ScheduleExceptionRule < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :schedule

  attr_accessor :user_duration_range_start, :user_duration_range_end

  [:user_duration_range_start, :user_duration_range_end].each do |method|
    define_method(method) do
      instance_variable_get(:"@#{method}").presence || send(method.to_s.sub('user_', ''))
    end
  end

  default_scope { order('created_at DESC') }

  def parse_user_input
    self.duration_range_start = date_time_handler.convert_to_datetime(user_duration_range_start).try(:beginning_of_day) if user_duration_range_start.present?
    self.duration_range_end = date_time_handler.convert_to_datetime(user_duration_range_end).try(:end_of_day) if user_duration_range_end.present?
    errors.add(:duration_range_end, :must_be_later) if duration_range_end.try(:<, duration_range_start) if duration_range_start.present?
    self.user_duration_range_start = duration_range_start
    self.user_duration_range_end = duration_range_end
    true
  end

  protected


  def date_time_handler
    @date_time_handler ||= DateTimeHandler.new
  end
end

