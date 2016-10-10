require 'test_helper'

class Api::V3::SpaceWizardsControllerTest < ActionController::TestCase
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
    at_attributes = action_type_attibutes(options)
    at_attributes[:action_types_attributes] = [at_attributes[:action_types_attributes]['0']]
    { 'user' =>
     { 'companies_attributes' =>       [
       {
         'name' => 'International Secret Intelligence Service',
         'company_address_attributes' => {
           'address' => 'Poznań, Polska',
           'latitude' => '52.406374',
           'longitude' => '16.925168100000064'
         },
         'locations_attributes' =>           [
           {
             'description' => "Our historic 11-story Southern Pacific Building, also known as \"The Landmark\", was completed in 1916. We are in the 172 m Spear Tower.",
             'name' => 'Location',
             'location_address_attributes' =>
             {
               'address' => 'usa',
               'local_geocoding' => '10',
               'latitude' => '5',
               'longitude' => '8',
               'formatted_address' => 'formatted usa'
             },
             'listings_attributes' =>               [
               {
                 'transactable_type_id' => TransactableType.first.id,
                 'name' => 'Desk',
                 'description' => 'We have a group of several shared desks available.',
                 'quantity' => '1',
                 'booking_type' => options[:booking_type] || 'regular',
                 'confirm_reservations' => '0',
                 'photos_attributes' => [FactoryGirl.attributes_for(:photo)],
                 'currency' => options[:currency],
                 'properties' => {
                   'listing_type' => 'Desk'
                 }
               }.merge(at_attributes)
             ]
           }
         ]
       }
     ],
       'country_name' => 'United States',
       'phone' => '123456789'
     },
      transactable_type_id: TransactableType.first.id
    }
  end

  def empty_params
    { 'user' =>
     { 'companies_attributes' =>       [
       {
         'name' => '',
         'locations_attributes' =>           { '0' =>            {
           'listings_attributes' =>              { '0' =>               {
             'transactable_type_id' => TransactableType.first.id
           }
           }
         }
         }
       }
     ],
       'country_name' => '',
       'phone' => ''
     },
      transactable_type_id: TransactableType.first.id
    }
  end
end
