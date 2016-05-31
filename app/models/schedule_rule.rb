class ScheduleRule < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :schedule, touch: true

  attr_accessor :time, :date

  RECURRING_MODE = 'recurring'.freeze
  SPECIFIC_MODE = 'specific'.freeze
  RANGE_MODE = 'range'.freeze

  RUN_HOURS_MODES = [RECURRING_MODE, SPECIFIC_MODE].freeze
  RUN_DATES_MODES = [RECURRING_MODE, SPECIFIC_MODE, RANGE_MODE].freeze

  validates_inclusion_of :run_hours_mode, in: RUN_HOURS_MODES, allow_nil: false
  validates :every_hours, numericality: { less_than: 24, greater_than: 0 }, if: -> { run_hours_mode == RECURRING_MODE }
  validates_presence_of :user_time_start, :user_time_end, if: -> { run_hours_mode == RECURRING_MODE }
  validates_length_of :user_times, minimum: 1, maximum: 50, if: -> { run_hours_mode == SPECIFIC_MODE }

  validates_inclusion_of :run_dates_mode, in: RUN_DATES_MODES, allow_nil: false
  validates_length_of :week_days, minimum: 1, if: -> { run_dates_mode == RECURRING_MODE }
  validates_presence_of :user_date_start, :date_end, if: -> { run_dates_mode == RANGE_MODE }
  validates_length_of :user_dates, minimum: 1, maximum: 50, if: -> { run_dates_mode == SPECIFIC_MODE }
  validate :dates_not_in_past, if: -> { run_dates_mode == RANGE_MODE }
  validate :range_not_too_wide, if: -> { run_dates_mode == RANGE_MODE }

  default_scope { order('created_at DESC') }

  attr_accessor :user_time_start, :user_time_end, :user_date_start, :user_date_end, :user_times, :user_dates

  [:user_time_start, :user_time_end, :user_date_start, :user_date_end, :user_times, :user_dates].each do |method|
    define_method(method) do
      instance_variable_get(:"@#{method}").presence || send(method.to_s.sub('user_', ''))
    end
  end

  def parse_user_input
    self.week_days = week_days.reject(&:blank?).map(&:to_i)
    self.times = (user_times || []).reject(&:blank?).map { |t| date_time_handler.convert_to_time(t) }
    self.dates = (user_dates || []).reject { |d| d.blank? }.map { |d| date_time_handler.convert_to_datetime(d) }.reject { |d| (d.blank? || (d.past? && !d.today?)) }
    self.time_start = date_time_handler.convert_to_time(user_time_start) if user_time_start.present?
    self.time_end = date_time_handler.convert_to_time(user_time_end) if user_time_end.present?
    self.date_start = date_time_handler.convert_to_datetime(user_date_start).try(:beginning_of_day) if user_date_start.present?
    self.date_end = date_time_handler.convert_to_datetime(user_date_end).try(:end_of_day) if user_date_end.present?
    errors.add(:user_date_end, :must_be_later) if date_end.try(:<, date_start) if date_start.present?
    errors.add(:user_time_end, :must_be_later) if time_end.try(:<, time_start) if time_start.present?
    self.user_times = times
    self.user_dates = dates
    self.user_time_start = time_start
    self.user_time_end = time_end
    self.user_date_start = date_start
    self.user_date_end = date_end
    true
  end

  protected

  def date_time_handler
    @date_time_handler ||= DateTimeHandler.new
  end

  def dates_not_in_past
    Time.use_zone(date_start.time_zone) do
      if date_start < Time.zone.now.beginning_of_day
        errors.add(:user_date_start, :not_in_past)
      end
      if date_end.present? && date_end < Time.zone.now.beginning_of_day
        errors.add(:user_date_end, :not_in_past)
      end
    end
  end

  def range_not_too_wide
    errors.add(:user_date_end, :range_too_wide) if date_start + 1.year < date_end
  end

end

