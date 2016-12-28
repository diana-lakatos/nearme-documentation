module Deliveries
  class CancellationPolicy
    attr_reader :delivery

    def initialize(delivery)
      @delivery = delivery
    end

    def allowed?
      case delivery.state
      when 'Transit', 'Delivered', 'Cancelled'
        false
      when 'Pickup'
        # should be 24h before pickup
        # should it be based on time-zone?
        delivery.pickup_date > Date.today
      else
        true
      end
    end
  end
end
