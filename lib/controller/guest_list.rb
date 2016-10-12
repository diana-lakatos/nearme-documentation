module Controller
  class GuestList
    attr_accessor :state, :reservations, :reservations_scope, :recurring_bookings, :recurring_bookings_scope

    DEFAULT_STATE = 'unconfirmed'

    def initialize(user, recurring_booking = nil)
      @user = user
      if recurring_booking
        @reservations_scope = recurring_booking.reservations.includes(transactable: :location)
      else
        reservations = @user.listing_orders.reservations.order('orders.updated_at DESC')
        @reservations_scope = reservations.includes(transactable: :location)
        @recurring_bookings_scope = @user.listing_recurring_bookings.includes(transactable: :location).order('orders.created_at DESC')
      end
    end

    def filter(state)
      if available_states.include? state
        @state = state
      else
        @state = DEFAULT_STATE
      end
      data = send(@state.to_sym)
      @reservations = data[:reservations].try(:decorate)
      @recurring_bookings = data[:recurring_bookings]
      self
    end

    def unconfirmed
      {
        reservations: @reservations_scope.upcoming.with_state(:unconfirmed),
        recurring_bookings: @recurring_bookings_scope ? @recurring_bookings_scope.with_state(:unconfirmed).order('created_at ASC').decorate : []
      }
    end

    def confirmed
      {
        reservations: @reservations_scope.upcoming.with_state(:confirmed),
        recurring_bookings: @recurring_bookings_scope ? @recurring_bookings_scope.with_state(:confirmed).order('starts_at ASC').decorate : []
      }
    end

    def archived
      {
        reservations: @reservations_scope.archived,
        recurring_bookings: @recurring_bookings_scope ? @recurring_bookings_scope.with_state(:rejected, :cancelled_by_host, :expired, :cancelled_by_guest).order('ends_at DESC').decorate : []
      }
    end

    def overdue
      {
        reservations: [],
        recurring_bookings: @recurring_bookings_scope ? @recurring_bookings_scope.with_state(:overdued).order('next_charge_date ASC').decorate : []
      }
    end

    private

    def available_states
      %w(unconfirmed confirmed archived overdue)
    end
  end
end
