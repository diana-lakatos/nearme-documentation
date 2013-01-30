require 'test_helper'

class Location::GoogleGeolocationDataParserTest < ActiveSupport::TestCase

  test 'parses geocoder output to avoid duplicated {long_name, short_name} pair ' do
    address_components = Location::GoogleGeolocationDataParser.new(FactoryGirl.build(:ursynowska_address_components).address_components)
    assert_equal "Ursynowska", address_components.street
    assert_equal "Mokotow", address_components.suburb
    assert_equal "Warsaw", address_components.city
    assert_equal "Masovian Voivodeship", address_components.state
    assert_equal "Poland", address_components.country
  end

end
