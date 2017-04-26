class ScheduleExceptionRule < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :schedule, touch: true
  belongs_to :availability_template, touch: true

  attr_accessor :user_duration_range_start, :user_duration_range_end

  [:user_duration_range_start, :user_duration_range_end].each do |method|
    define_method(method) do
      instance_variable_get(:"@#{method}").presence || send(method.to_s.sub('user_', ''))
    end
  end

  default_scope { order('created_at ASC') }

  scope :at, -> (date) { where('duration_range_start <= ? AND duration_range_end >= ?', date, date) }
  scope :future, -> (date = Date.current) { where('duration_range_end >= ?', date) }

  validate :end_time_after_start_time
  validates :duration_range_end, :duration_range_start, presence: true

  def parse_user_input
    self.duration_range_start = date_time_handler.convert_to_datetime(user_duration_range_start) if user_duration_range_start.present?
    self.duration_range_end = date_time_handler.convert_to_datetime(user_duration_range_end) if user_duration_range_end.present?
    errors.add(:duration_range_end, :must_be_later) if duration_range_end.try(:<, duration_range_start) if duration_range_start.present?
    self.user_duration_range_start = duration_range_start
    self.user_duration_range_end = duration_range_end
    true
  end

  def end_time_after_start_time
    errors.add(:user_duration_range_end, :after) if end_time_before_start_time?
  end

  def end_time_before_start_time?
    duration_range_end.present? && duration_range_start.present? && duration_range_start > duration_range_end
  end

  def to_liquid
    @schedule_exception_rule_drop ||= ScheduleExceptionRuleDrop.new(self)
  end

  def range
    { from: duration_range_start.to_date, to: duration_range_end.to_date }
  end

  def all_dates
    (duration_range_start.to_date..duration_range_end.to_date).map(&:to_date)
  end

  def time_range
    (duration_range_start.beginning_of_day..duration_range_end.end_of_day)
  end

  def schedulable
    availability_template || schedule
  end

  protected

  def date_time_handler
    @date_time_handler ||= DateTimeHandler.new
  end
end
