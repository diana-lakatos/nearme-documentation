module Controller
  class GuestList
    attr_accessor :state, :reservations, :reservations_scope, :recurring_bookings, :recurring_bookings_scope

    DEFAULT_STATE = 'unconfirmed'

    def initialize(user, recurring_booking = nil)
      @user = user
      if recurring_booking
        @reservations_scope = recurring_booking.reservations.includes(:listing => :location)
      else
        @reservations_scope = @user.listing_reservations.includes(:listing => :location).no_recurring
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
