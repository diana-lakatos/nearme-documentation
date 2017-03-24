module Deliveries
  class CancellationPolicy
    attr_reader :delivery

    def initialize(delivery)
      @delivery = delivery
    end

    def allowed?
      case delivery.courier
      when 'auspost-manual', 'manual' then Manual.new(delivery).allowed?
      when 'sendle' then Sendle.new(delivery).allowed?
      end
    end

    # TODO: refactor -> move to separate lib-module each for provider
    # add to registry and fetch proper object from registry based on courier
    class Sendle
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

    class Manual
      attr_reader :delivery

      def initialize(delivery)
        @delivery = delivery
      end

      def allowed?
        delivery.pickup_date >= Date.today
      end
    end
  end
end
