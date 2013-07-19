FactoryGirl.define do
  factory :location do
    address "42 Wallaby Way"
    email "psherman@smilehouse.com"
    description "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    latitude "-33.856944"
    longitude "151.215278"
    availability_template_id "M-F9-5"
    association(:location_type, factory: :location_type)
    company

    factory :location_in_auckland do
      address "Parnell, Auckland 1010 New Zealand"
      latitude "-36.858675"
      longitude "174.777303"
      association(:company, factory: :company_in_auckland)
    end

    factory :location_in_adelaide do
      address "Adelaide"
      latitude "-41.4391386"
      longitude "147.1405474"
      association(:company, factory: :company_in_adelaide)
    end

    factory :location_in_cleveland do
      address "1100 Rock and Roll Boulevard"
      latitude "41.508806"
      longitude "-81.69548"
      association(:company, factory: :company_in_cleveland)
    end

    factory :location_in_san_francisco do
      address "Golden Gate Bridge"
      latitude "37.819959"
      longitude "-122.478696"
      association(:company, factory: :company_in_san_francisco)
    end

    factory :location_in_wellington do
      address "35 Ghuznee Street"
      latitude "-41.293597"
      longitude "174.7763361"
      association(:company, factory: :company_in_wellington)
    end

    factory :location_ursynowska_address_components do
      formatted_address "Ursynowska, Warsaw, Poland"
      address_components do
        {
          "0"=> {
          "long_name"=>"Ursynowska",
          "short_name"=>"Ursynowska",
          "types"=>["route"]
        },
          "1"=>{
          "long_name"=>"Mokotow",
          "short_name"=>"Mokotow",
          "types"=>["sublocality","political"]
        },
          "2"=>{
          "long_name"=>"Warsaw",
          "short_name"=>"Warsaw",
          "types"=>["locality","political"]
        },
          "3"=>{
          "long_name"=> "Warszawa",
          "short_name"=>"Warszawa",
          "types"=>["administrative_area_level_3","political"]
        },
          "4"=>{
            "long_name"=>"Warszawa",
            "short_name"=>"Warszawa",
            "types"=>["administrative_area_level_2","political"]
          },
          "5"=>{
            "long_name"=>"Masovian Voivodeship",
            "short_name"=>"Masovian Voivodeship",
            "types"=>["administrative_area_level_1","political"]
          },
          "6"=>{
            "long_name"=>"Poland",
            "short_name"=>"PL",
            "types"=>["country","political"]
          }
        }
      end
    end

    factory :location_warsaw_address_components do
      formatted_address "Warsaw"
      address_components {{
        "2"=>{
          "long_name"=>"Warsaw",
          "short_name"=>"Warsaw",
          "types"=>["locality","political"]
        },
          "3"=>{
          "long_name"=> "Warszawa",
          "short_name"=>"Warszawa",
          "types"=>["administrative_area_level_3","political"]
        }
      }}
    end

    factory :location_san_francisco_address_components do
      formatted_address "San Francisco, CA, USA"
      address_components{{
        "0"=>{
          "long_name"=>"San Francisco",
          "short_name"=>"SF",
          "types"=>["locality","political"]
        },
        "1"=>{
          "long_name"=>"San Francisco",
          "short_name"=>"San Francisco",
          "types"=>["administrative_area_level_2","political"]},
        "2"=>{
          "long_name"=>"California",
          "short_name"=>"CA",
          "types"=>["administrative_area_level_1","political"]},
        "3"=>{
          "long_name"=>"United States",
          "short_name"=>"US",
          "types"=>["country","political"]
        }
      }}
    end

    factory :location_vaughan_address_components do
      formatted_address "Major MacKenzie Drive, Vaughan, ON L6A, Canada"
      address_components{{
         "0"=> {
          "long_name"=>"Major MacKenzie Drive",
          "short_name"=>"Major MacKenzie Dr",
          "types"=>["route"]},
        "1"=>{
          "long_name"=>"Maple",
          "short_name"=>"Maple",
          "types"=>["neighborhood","political"]},
        "2"=>{
          "long_name"=>"Vaughan",
          "short_name"=>"Vaughan",
          "types"=>["administrative_area_level_3","political"]},
        "3"=>{
          "long_name"=>"York Regional Municipality",
          "short_name"=>"York Regional Municipality",
          "types"=>["administrative_area_level_2","political"]},
        "4"=>{
          "long_name"=>"Ontario",
          "short_name"=>"ON",
          "types"=>["administrative_area_level_1","political"]},
        "5"=>{
          "long_name"=>"Canada",
          "short_name"=>"CA",
          "types"=>["country","political"]},
        "6"=>{
          "long_name"=>"L6A",
          "short_name"=>"L6A",
          "types"=>["postal_code"]}
      }}
    end
  end
end
