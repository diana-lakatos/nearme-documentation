# frozen_string_literal: true
FactoryGirl.define do
  factory :address do
    address '42 Wallaby Way, North Highlands, California'
    latitude '-33.856944'
    longitude '151.215278'
    country 'US'

    address_components do
      {
        '0' => {
          'long_name' => 'United States',
          'short_name' => 'US',
          'types' => %w(country political)
        }
      }
    end

    factory :address_in_auckland do
      city 'Auckland'
      address '40 St Georges Bay Rd, Parnell, Auckland 1052, Nowa Zelandia'
      latitude '-36.858675'
      longitude '174.777303'
      address_components do
        {
          '0' => {
            'long_name' => 'New Zealand',
            'short_name' => 'NZ',
            'types' => %w(country political)
          }
        }
      end
    end

    factory :full_address_in_sf do
      address '125 Ellis St, San Francisco, CA 94102'
      latitude '37.819959'
      longitude '-122.478696'
      state 'California'
      city 'San Francisco'
      suburb 'San Francisco'
      street 'Ellis St'
      country 'United States'
      iso_country_code 'US'
      postcode '94102'
      after(:build) do |model, evaluator|
        model.instance_variable_set(:@state_code, 'CA')
      end
    end

    factory :address_in_adelaide do
      address '233 Grote St, Adelaide SA 5000, Australia'
      latitude '-41.4391386'
      longitude '147.1405474'
    end

    factory :address_in_cleveland do
      address '1100 Rock and Roll Boulevard, Cleveland, Ohio'
      latitude '41.508806'
      longitude '-81.69548'
    end

    factory :address_in_san_francisco do
      address '125 Ellis St, San Francisco, CA 94102'
      latitude '37.819959'
      longitude '-122.478696'
      state 'California'
    end

    factory :address_in_wellington do
      address '35 Ghuznee Street'
      latitude '-41.293597'
      longitude '174.7763361'
    end

    factory :address_czestochowa do
      formatted_address 'Aleja Niepodległości 40, Czestochowa, Poland'
      address 'Aleja Niepodległości 40, Czestochowa, Poland'
      street 'Aleja Niepodległości 40'
      latitude '-36.858675'
      longitude '174.777303'
    end

    factory :address_rydygiera do
      formatted_address 'Ludwika Rydygiera 8, 01-793 Warsaw, Poland'
      address 'Ludwika Rydygiera 8, 01-793 Warsaw, Poland'
      street 'Ludwika Rydygiera 8'
      latitude '-36.858675'
      longitude '174.777303'
    end

    factory :address_bronx_address_components do
      formatted_address "754 Coster St, Bronx, NY 10474, USA"
      address_components do
        {
          "0"=>{
            "long_name"=>"754",
            "short_name"=>"754",
            "types"=>["street_number"]
          },
          "1"=>{
            "long_name"=>"Coster Street",
            "short_name"=>"Coster St",
            "types"=>["route"]
          },
         "2"=>{
            "long_name"=>"West Bronx",
            "short_name"=>"West Bronx",
            "types"=>["neighborhood", "political"]
          },
         "3"=>{
            "long_name"=>"Bronx",
            "short_name"=>"Bronx",
            "types"=>["political", "sublocality", "sublocality_level_1"]
          },
         "4"=>{
            "long_name"=>"Bronx County",
            "short_name"=>"Bronx County",
            "types"=>["administrative_area_level_2", "political"]
          },
         "5"=>{
            "long_name"=>"New York",
            "short_name"=>"NY",
            "types"=>["administrative_area_level_1", "political"]
          },
         "6"=>{
            "long_name"=>"United States",
            "short_name"=>"US",
            "types"=>["country", "political"]
          },
         "7"=>{
            "long_name"=>"10474",
            "short_name"=>"10474",
            "types"=>["postal_code"]
          }}
      end
    end

    factory :address_ursynowska_address_components do
      formatted_address 'Ursynowska, Warsaw, Poland'
      address_components do
        {
          '0' => {
            'long_name' => 'Ursynowska',
            'short_name' => 'Ursynowska',
            'types' => ['route']
          },
          '1' => {
            'long_name' => 'Mokotow',
            'short_name' => 'Mokotow',
            'types' => %w(sublocality political)
          },
          '2' => {
            'long_name' => 'Warsaw',
            'short_name' => 'Warsaw',
            'types' => %w(locality political)
          },
          '3' => {
            'long_name' => 'Warszawa',
            'short_name' => 'Warszawa',
            'types' => %w(administrative_area_level_3 political)
          },
          '4' => {
            'long_name' => 'Warszawa',
            'short_name' => 'Warszawa',
            'types' => %w(administrative_area_level_2 political)
          },
          '5' => {
            'long_name' => 'Masovian Voivodeship',
            'short_name' => 'Masovian Voivodeship',
            'types' => %w(administrative_area_level_1 political)
          },
          '6' => {
            'long_name' => 'Poland',
            'short_name' => 'PL',
            'types' => %w(country political)
          },
          '7' => {
            'long_name' => '02-690',
            'short_name' => '02-690',
            'types' => ['postal_code']
          }
        }
      end
    end

    factory :address_warsaw_address_components do
      formatted_address 'Warsaw'
      address_components do
        {
          '2' => {
            'long_name' => 'Warsaw',
            'short_name' => 'Warsaw',
            'types' => %w(locality political)
          },
          '3' => {
            'long_name' => 'Warszawa',
            'short_name' => 'Warszawa',
            'types' => %w(administrative_area_level_3 political)
          },
          '4' => {
            'long_name' => 'Poland',
            'short_name' => 'PL',
            'types' => %w(country political)
          }
        }
      end
    end

    factory :address_san_francisco_address_components do
      formatted_address 'San Francisco, CA, USA'
      address_components do
        {
          '0' => {
            'long_name' => 'San Francisco',
            'short_name' => 'SF',
            'types' => %w(locality political)
          },
          '1' => {
            'long_name' => 'San Francisco',
            'short_name' => 'San Francisco',
            'types' => %w(administrative_area_level_2 political)
          },
          '2' => {
            'long_name' => 'California',
            'short_name' => 'CA',
            'types' => %w(administrative_area_level_1 political)
          },
          '3' => {
            'long_name' => 'United States',
            'short_name' => 'US',
            'types' => %w(country political)
          }
        }
      end
    end

    factory :address_vaughan_address_components do
      formatted_address 'Major MacKenzie Drive, Vaughan, ON L6A, Canada'
      address_components do
        {
          '0' => {
            'long_name' => 'Major MacKenzie Drive',
            'short_name' => 'Major MacKenzie Dr',
            'types' => ['route']
          },
          '1' => {
            'long_name' => 'Maple',
            'short_name' => 'Maple',
            'types' => %w(neighborhood political)
          },
          '2' => {
            'long_name' => 'Vaughan',
            'short_name' => 'Vaughan',
            'types' => %w(administrative_area_level_3 political)
          },
          '3' => {
            'long_name' => 'York Regional Municipality',
            'short_name' => 'York Regional Municipality',
            'types' => %w(administrative_area_level_2 political)
          },
          '4' => {
            'long_name' => 'Ontario',
            'short_name' => 'ON',
            'types' => %w(administrative_area_level_1 political)
          },
          '5' => {
            'long_name' => 'Canada',
            'short_name' => 'CA',
            'types' => %w(country political)
          },
          '6' => {
            'long_name' => 'L6A',
            'short_name' => 'L6A',
            'types' => ['postal_code']
          }
        }
      end
    end
  end
end
