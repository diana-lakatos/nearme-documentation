require 'test_helper'

class Api::V2::SpaceWizardsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    set_authentication_header(@user)
  end

  should 'create transactable' do
    stub_us_geolocation
    assert_difference('Transactable.count', 1) do
      post :create, get_params.merge(format: :json)
    end
    assert_equal ApiSerializer.serialize_object(assigns(:user).first_listing), JSON.parse(response.body)
  end

  should 'render validation errors if params incomplete' do
    assert_no_difference('Transactable.count') do
      post :create, empty_params.merge(format: :json)
      assert_equal ApiSerializer.serialize_errors(assigns(:user).errors), JSON.parse(response.body)
    end
  end

  private

  def get_params(options = {})
    free = options[:daily_price].to_f + options[:weekly_price].to_f + options[:monthly_price].to_f == 0
    options.reverse_merge!(daily_price: nil, weekly_price: nil, monthly_price: nil, free: free, currency: 'USD')
    {"user" =>
     {"companies_attributes"=>
      {"0" =>
       {
         "name"=>"International Secret Intelligence Service",
         "company_address_attributes" => {
           "address" => "Poznań, Polska",
           "latitude" => "52.406374",
           "longitude" => "16.925168100000064",
         },
         "locations_attributes"=>
         {"0"=>
          {
            "description"=>"Our historic 11-story Southern Pacific Building, also known as \"The Landmark\", was completed in 1916. We are in the 172 m Spear Tower.",
            "name" => 'Location',
            "location_address_attributes" =>
            {
              "address"=>"usa",
              "local_geocoding"=>"10",
              "latitude"=>"5",
              "longitude"=>"8",
              "formatted_address"=>"formatted usa",
            },
            "listings_attributes"=>
            {"0"=>
             {
               "transactable_type_id" => TransactableType.first.id,
               "name"=>"Desk",
               "description"=>"We have a group of several shared desks available.",
               "action_hourly_booking" => false,
               "quantity"=>"1",
               "booking_type" => options[:booking_type] || 'regular',
               "daily_price"=>options[:daily_price],
               "fixed_price"=>options[:fixed_price],
               "weekly_price"=>options[:weekly_price],
               "monthly_price"=> options[:monthly_price],
               "action_free_booking"=>options[:free],
               "confirm_reservations"=>"0",
               "photos_attributes" => [FactoryGirl.attributes_for(:photo)],
               "currency"=>options[:currency],
               "properties" => {
                 "listing_type"=>"Desk",
               }
             }
            },
          }
         }
       },
      },
      "country_name" => "United States",
      "phone" => "123456789"
     },
     transactable_type_id: TransactableType.first.id
    }
  end

  def empty_params
    {"user" =>
     {"companies_attributes"=>
      {"0" =>
       {
         "name"=>"",
         "locations_attributes"=>
         {"0"=>
          {
            "listings_attributes"=>
            {"0"=>
             {
               "transactable_type_id" => TransactableType.first.id,
             }
            },
          }
         }
       },
      },
      "country_name" => "",
      "phone" => ""
     },
     transactable_type_id: TransactableType.first.id
    }
  end

end

