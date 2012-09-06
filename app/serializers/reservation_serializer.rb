class ReservationSerializer < ApplicationSerializer

  attribute :id
  attribute :owner_id,  :key => :user_id
  attributes :listing_id, :state
  attributes :cancelable, :total_cost

  attribute :periods, :key => :times

  ##
  ##
  private

  # Return the reservation periods as a hash in the same format as the API spec
  def periods

    object.periods.map do |p|

      # Use a start/end time that spans the entire day
      timestamp_start = p.date.to_time(:utc)
      timestamp_end = timestamp_start + 1.day - 1

      {
          # Period ID
          id: p.id,
          # Period date range
          start_at: timestamp_start,
          end_at: timestamp_end,
          # Who's assigned the desks
          assignee: object.seats.map { |s|
            {
                name: s.name,
                email: s.email
            }
          }
      }
    end

  end

  def total_cost

    {
      amount:        object.total_amount.to_f,
      label:         object.total_amount.format,
      currency_code: object.total_amount.currency.iso_code
    }

  end

end
