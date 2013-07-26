class ReservationSerializer < ApplicationSerializer

  attribute :id
  attribute :owner_id,  :key => :user_id
  attributes :listing_id, :state
  attributes :cancelable, :total_cost

  attribute :periods, :key => :times

  private

  # Return reservation states as expected by the mobile application
  RESERVATION_STATES = {
    unconfirmed:  'pending',
    confirmed:    'confirmed',
    rejected:     'rejected',
    cancelled:    'canceled'
  }

  def state
    RESERVATION_STATES[object.state.to_sym]
  end

  # Return the reservation periods as a hash in the same format as the API spec
  def periods
    object.periods.map do |p|
      # Use a start/end time that spans the entire day
      timestamp_start = p.date.beginning_of_day
      timestamp_end = timestamp_start + 1.day - 1

      {
        # Period ID
        id: p.id,
        # Period date range
        start_at: timestamp_start,
        end_at: timestamp_end,
        # Who's assigned the desks
        assignee: object.quantity.times.to_a.map { |s|
          {
            name: object.owner.try(:name),
            email: object.owner.try(:email)
          }
        }
      }
    end
  end

  def total_cost
    object.total_amount ||= 0

    {
      amount:        object.total_amount.to_f,
      label:         object.total_amount.format,
      currency_code: object.total_amount.currency.iso_code
    }
  end
end
