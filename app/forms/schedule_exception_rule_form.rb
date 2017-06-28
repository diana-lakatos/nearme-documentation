# frozen_string_literal: true
class ScheduleExceptionRuleForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections

  # @!attribute id
  #   @return [Integer] numeric indentifier for the schedule exception
  property :id

  property :_destroy, virtual: true

  # @!attribute label
  #   @return [String] description label for the schedule exception
  property :label

  # @!attribute user_duration_range_start
  #   @return [Date] when this schedule exception rule starts
  property :user_duration_range_start

  # @!attribute user_duration_range_end
  #   @return [Date] when this schedule exception rule ends
  property :user_duration_range_end

  validate :end_time_after_start_time, unless: -> { model.marked_for_destruction? }
  validates :user_duration_range_end, :user_duration_range_start, presence: true, unless: -> { model.marked_for_destruction? }

  def _destroy=(value)
    model.mark_for_destruction if value == '1'
  end

  def _destroy
    '1' if model.marked_for_destruction?
  end

  def user_duration_range_start=(date)
    super(date_time_handler.convert_to_datetime(date))
  end

  def user_duration_range_end=(date)
    super(date_time_handler.convert_to_datetime(date))
  end

  protected

  def end_time_after_start_time
    errors.add(:user_duration_range_end, :after) if end_time_before_start_time?
  end

  def end_time_before_start_time?
    user_duration_range_end.present? && user_duration_range_start.present? && user_duration_range_start > user_duration_range_end
  end
end
