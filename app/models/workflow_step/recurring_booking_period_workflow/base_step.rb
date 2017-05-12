# frozen_string_literal: true
class WorkflowStep::RecurringBookingPeriodWorkflow::BaseStep < WorkflowStep::BaseStep
  def self.belongs_to_transactable_type?
    true
  end

  def initialize(recurring_booking_period_id)
    @recurring_booking_period = RecurringBookingPeriod.find_by(id: recurring_booking_period_id)
    @recurring_booking = @recurring_booking_period.recurring_booking
    @lister = @recurring_booking&.host
    @enquirer = @recurring_booking&.owner
  end

  def workflow_type
    'recurring_booking_period'
  end

  def data
    {
      recurring_booking_period: @recurring_booking_period,
      recurring_booking: @recurring_booking,
      enquirer: enquirer,
      lister: lister,
      listing: @recurring_booking.transactable
    }
  end

  def transactable_type_id
    @recurring_booking.transactable.transactable_type_id
  end

  def should_be_processed?
    @recurring_booking.present?
  end
end
