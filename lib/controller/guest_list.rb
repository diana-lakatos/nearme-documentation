module Controller
  class GuestList
    attr_accessor :state, :reservations, :scope

    DEFAULT_STATE = 'unconfirmed'

    def initialize(user, platform_context)
      @user = user
      @scope = @user.listing_reservations.for_instance(platform_context.instance).includes(:listing => :location)
    end

    def filter(state)
      if available_states.include? state
        @state = state
      else
        @state = DEFAULT_STATE
      end
      @reservations = send(@state.to_sym).sort_by(&:date).reverse
      self
    end

    def unconfirmed
      @scope.upcoming.with_state :unconfirmed
    end

    def confirmed
      @scope.upcoming.with_state :confirmed
    end

    def archived
      @scope.select(&:archived?)
    end

    private

    def available_states
      %w{unconfirmed confirmed archived}
    end
  end
end
