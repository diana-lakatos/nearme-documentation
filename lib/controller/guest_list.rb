module Controller
  class GuestList
    attr_accessor :state, :reservations, :reservations_scope, :recurring_bookings, :recurring_bookings_scope

    DEFAULT_STATE = 'unconfirmed'

    def initialize(user, recurring_booking = nil)
      @user = user
      if recurring_booking
        @reservations_scope = recurring_booking.reservations.includes(:listing => :location)
      else
        # We need to add reorder to the reservations, since in rails 4.1 for strange reason to the query
        # is added 'ORDER BY "company_user"."created"_at ASC' and when we call uniq to get distinct records from reservations
        # we get postgresql error 'SELECT DISTINCT, ORDER BY expressions must appear in select list'
        reservations = @user.listing_reservations.reorder("created_at ASC")
        @reservations_scope = reservations.includes(:listing => :location).no_recurring
        @recurring_bookings_scope = @user.listing_recurring_bookings.includes(:listing => :location)
      end
    end

    def filter(state)
      if available_states.include? state
        @state = state
      else
        @state = DEFAULT_STATE
      end
      data = send(@state.to_sym)
      @reservations = data[:reservations].sort_by(&:date).reverse.map(&:decorate)
      @recurring_bookings = data[:recurring_bookings].sort_by(&:start_on).reverse.map(&:decorate)
      self
    end

    def unconfirmed
      {
        reservations: @reservations_scope.upcoming.with_state(:unconfirmed),
        recurring_bookings: @recurring_bookings_scope ? @recurring_bookings_scope.upcoming.with_state(:unconfirmed) : []
      }
    end

    def confirmed
      {
        reservations: @reservations_scope.upcoming.with_state(:confirmed),
        recurring_bookings: @recurring_bookings_scope ? @recurring_bookings_scope.upcoming.with_state(:confirmed) : []
      }
    end

    def archived
      {
        reservations: @reservations_scope.select(&:archived?),
        recurring_bookings: @recurring_bookings_scope ? @recurring_bookings_scope.select(&:archived?) : []
      }
    end

    private

    def available_states
      %w{unconfirmed confirmed archived}
    end
  end
end
