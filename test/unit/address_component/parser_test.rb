require 'test_helper'

class AddressComponent::ParserTest < ActiveSupport::TestCase

  test 'parses geocoder output to avoid duplicated {long_name, short_name} pair ' do
    assert_equal(
      {
      0 => { 
        "short_name" => "Ursynowska",
        "long_name" => "Ursynowska",
        "types" => ["route"]
      },
      1 => { 
        "short_name" => "Mokotow",
        "long_name" => "Mokotow",
        "types" => ["sublocality", "political"]
      },
      2=>{
        "short_name"=>"Warsaw", 
        "long_name"=>"Warsaw", 
        "types"=>["locality" ,"political"]
      },
      3 => {
        "short_name" => "Warszawa",
        "long_name" => "Warszawa",
        "types" => ["administrative_area_level_3", "political", "administrative_area_level_2"]
      },
      4 =>{
        "short_name"=>"Masovian Voivodeship", 
        "long_name"=>"Masovian Voivodeship", 
        "types"=> ["administrative_area_level_1","political"]
      }, 
      5 =>{
        "short_name"=>"PL", 
        "long_name"=>"Poland", 
        "types"=> ["country", "political"]
      }
    },
      AddressComponent::Parser::parse_geocoder_address_component_hash(get_params_for_address_components)
    )

  end

  private 

  def get_params_for_address_components
    # real data from google geocoder
    {
      "0"=> {
      "long_name"=>"Ursynowska", 
      "short_name"=>"Ursynowska", 
      "types"=>"route"
    }, 
      "1"=>{
      "long_name"=>"Mokotow", 
      "short_name"=>"Mokotow", 
      "types"=>"sublocality,political"
    }, 
      "2"=>{
      "long_name"=>"Warsaw", 
      "short_name"=>"Warsaw", 
      "types"=>"locality,political"
    },
      "3"=>{
      "long_name"=> "Warszawa", 
      "short_name"=>"Warszawa", 
      "types"=>"administrative_area_level_3,political"
    }, 
      "4"=>{
      "long_name"=>"Warszawa", 
      "short_name"=>"Warszawa", 
      "types"=>"administrative_area_level_2,political"
    }, 
      "5"=>{
      "long_name"=>"Masovian Voivodeship", 
      "short_name"=>"Masovian Voivodeship", 
      "types"=>"administrative_area_level_1,political"
    }, 
      "6"=>{
      "long_name"=>"Poland", 
      "short_name"=>"PL", 
      "types"=>"country,political"
    }
    }
  end

end
