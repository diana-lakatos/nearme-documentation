require 'test_helper'

class Location::AddressComponentTest < ActiveSupport::TestCase

  test 'parses geocoder output to avoid duplicated {long_name, short_name} pair ' do
    assert_equal(
      {
      "street" => "Ursynowska",
      "suburb" => "Mokotow",
      "city"=>"Warsaw", 
      "state"=>"Masovian Voivodeship", 
      "country"=>"Poland"
    },
      Location::AddressComponent::Parser::parse_geocoder_address_component_hash(FactoryGirl.build(:ursynowska_address_components).address_components_hash)
    )

  end

end
