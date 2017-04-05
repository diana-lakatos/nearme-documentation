# frozen_string_literal: true
class ReservationPeriodForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  property :date
  validates :date, presence: true
  validate do
    errors.add(:date, 'must be in the future') if Date.parse(date).in_time_zone + start_minute.to_i.minutes < Time.now
  end

  class << self
    def decorate(configuration)
      Class.new(self) do
        %i(start_minute end_minute).each do |field|
          property :"#{field}", configuration.dig(field, :property_options) || {}
          validates :"#{field}", configuration.dig(field, :validation) if configuration.dig(field, :validation).present?
        end
        validate :validate_minimum_booking_minutes if configuration[:validate_minimum_booking_minutes]
      end
    end
  end

  # FIXME: find better way? :|
  def validate_minimum_booking_minutes
    errors.add(:end_minute, "must be at least #{model.reservation.minimum_booking_minutes} minutes") if start_minute.to_i + model.reservation.minimum_booking_minutes > end_minute.to_i
  end
end
