require 'holidays'

module Deliveries
  class Sendle
    module Validations
      # TODO: the class name sux
      class PossiblePickupDates
        def initialize(to:, from: Date.today, time_zone:, estimated_delivery: 1)
          @to = to
          @from = from
          @time_zone = time_zone
          @estimated_delivery = estimated_delivery
        end

        def any?
          possible_dates.size > @estimated_delivery
        end

        def possible_dates
          range.reject do |day|
            non_business_day?(day) || cannot_pickup(day)
          end
        end

        # check if it's before 5pm at pickup location
        def cannot_pickup(day)
          day.in_time_zone(@time_zone.name).end_of_day.advance(hours: -7) < current_time_at_sender
        end

        def current_time_at_sender
          @time_zone.now
        end

        def range
          Range.new @from, @to.advance(days: -1)
        end

        def non_business_day?(day)
          day.sunday? || day.saturday? || holiday?(day)
        end

        def holiday?(date, country_list = [:au])
          Holidays.on(date, *country_list).any?
        end
      end
    end
  end
end
