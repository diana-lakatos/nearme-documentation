# frozen_string_literal: true
class EventBookingForm < ActionTypeForm
  property :type, default: 'Transactable::EventBooking'
  property :schedule

  class << self
    def decorate(configuration)
      Class.new(self) do
        super
        if (schedule_configuration = configuration.delete(:schedule)).present?
          validation = schedule_configuration.delete(:validation)
          validates :schedule, validation if validation.present?
          property :schedule, form: ScheduleForm.decorate(schedule_configuration),
                                prepopulator: ->(option) { self.schedule ||= build_schedule },
                                populate_if_empty: -> (fragment:, **) { model.build_schedule }
        end
      end
    end
  end

  def build_schedule
    model.build_schedule(
      schedule: model.transactable_type_action_type.schedule.try(:schedule).try(:to_hash).try(:to_json)
    )
  end
end
