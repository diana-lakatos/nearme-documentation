# frozen_string_literal: true
require 'test_helper_lite'
require 'active_support/time'
require 'active_support/time_with_zone'
require 'active_support/core_ext/time/zones'
require 'active_model'
# require './app/models/deliveries'
require './app/models/deliveries/validations'
require './app/models/deliveries/sendle/validations/possible_pickup_dates'
require 'pry'
require 'date'

# [
#   ['Perth',     Sun, '18 Dec 2016 23:17:45 AWST +08:00'],
#   ['Adelaide',  Mon, '19 Dec 2016 01:47:45 ACDT +10:30'],
#   ['Darwin',    Mon, '19 Dec 2016 00:47:45 ACST +09:30'],
#   ['Brisbane',  Mon, '19 Dec 2016 01:17:45 AEST +10:00'],
#   ['Canberra',  Mon, '19 Dec 2016 02:17:45 AEDT +11:00'],
#   ['Hobart',    Mon, '19 Dec 2016 02:17:45 AEDT +11:00'],
#   ['Melbourne', Mon, '19 Dec 2016 02:17:45 AEDT +11:00'],
#   ['Sydney',    Mon, '19 Dec 2016 02:17:45 AEDT +11:00']
# ]

def australia_time_zones
  ActiveSupport::TimeZone.all.select { |tz| tz.tzinfo.name =~ /Australia/ }
end

class Deliveries::Sendle::Validations::PossiblePickupDatesTest < ActiveSupport::TestCase
  test 'general validations' do
    delivery_date = Date.today.advance(days: 10)
    time_zone = australia_time_zones.first

    dates = Deliveries::Sendle::Validations::PossiblePickupDates.new(to: delivery_date, time_zone: time_zone)

    assert dates.any?
  end
end
