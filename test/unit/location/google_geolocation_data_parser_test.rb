require 'test_helper'

class Location::GoogleGeolocationDataParserTest < ActiveSupport::TestCase

  test 'parses geocoder output to avoid duplicated {long_name, short_name} pair ' do
    address_components = Location::GoogleGeolocationDataParser.new(FactoryGirl.build(:location_ursynowska_address_components).address_components)
    assert_equal "Ursynowska", address_components.fetch_address_component("street")
    assert_equal "Mokotow", address_components.fetch_address_component("suburb")
    assert_equal "Warsaw", address_components.fetch_address_component("city")
    assert_equal "Masovian Voivodeship", address_components.fetch_address_component("state")
    assert_equal "Poland", address_components.fetch_address_component("country")
  end

  test 'using administrative_area_level_3 as city if city is nil ' do
    address_components = Location::GoogleGeolocationDataParser.new(FactoryGirl.build(:location_vaughan_address_components).address_components)
    assert_equal "Major MacKenzie Drive", address_components.fetch_address_component("street")
    assert_equal "Vaughan", address_components.fetch_address_component("city")
    assert_equal "Ontario", address_components.fetch_address_component("state")
    assert_equal "Canada", address_components.fetch_address_component("country")
  end

  test 'using neighborhood as suburb if suburb is nil ' do
    address_components = Location::GoogleGeolocationDataParser.new(FactoryGirl.build(:location_vaughan_address_components).address_components)
    assert_equal "Maple", address_components.fetch_address_component("suburb")
  end

end
