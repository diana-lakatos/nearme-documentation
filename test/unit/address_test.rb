require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  should validate_presence_of(:address)
  should validate_presence_of(:latitude)
  should validate_presence_of(:longitude)

  setup do
    stub_us_geolocation
  end

  context 'geolocate ourselves' do
    should 'not be valid if cannot geolocate' do
      @address = FactoryGirl.create(:address)
      stub_request(:get, 'http://maps.googleapis.com/maps/api/geocode/json?address=this%20does%20not%20exists%20at%20all&language=en&sensor=false').to_return(status: 200, body: '{}', headers: {})
      @address.address = 'this does not exists at all'
      refute @address.save
      assert @address.errors.include?(:latitude)
    end
  end

  context 'creating address components' do
    setup do
      @address = FactoryGirl.create(:address_ursynowska_address_components)
    end

    context 'creates address components for new record' do
      should 'store address components' do
        assert_equal(8, @address.address_components.count)
      end

      should 'be able to get city, suburb, state, country and postal code' do
        assert_equal 'Ursynowska', @address.street
        assert_equal 'Warsaw', @address.city
        assert_equal 'Mokotow', @address.suburb
        assert_equal 'Masovian Voivodeship', @address.state
        assert_equal 'Poland', @address.country
        assert_equal '02-690', @address.postcode
      end

      should 'ignore missing fields and store the one present' do
        @address = FactoryGirl.create(:address_warsaw_address_components)
        assert_equal 'Warsaw', @address.city
        assert_equal 'Warsaw', @address.suburb
      end
    end

    should 'handle trash' do
      @address.address_components = { 0 => { 'does' => 'not', 'exist' => ', but', 'should' => 'work' } }
      @address.save!
      @address.reload
      assert_equal nil, @address.city
    end

    should 'should update all address components fields based on address_components' do
      @address.attributes = FactoryGirl.attributes_for(:address_san_francisco_address_components)
      assert_not_equal 'San Francisco', @address.city
      @address.parse_address_components
      assert_equal 'San Francisco', @address.city
      assert_equal 'California', @address.state
      assert_equal 'United States', @address.country
      assert_equal 'San Francisco', @address.suburb
      assert_equal 'San Francisco', @address.street # this is first part of address
    end
  end

  context 'update fields from coords' do
    should 'call fetch address on new object with coords' do
      @address = Address.new
      @address.latitude = 44.25
      @address.longitude = 26.11
      assert true, @address.should_fetch_address?
    end

    should 'call fetch address on object with changed coords' do
      @address = FactoryGirl.create(:address)
      @address.latitude = 44.25
      @address.longitude = 26.11
      assert true, @address.should_fetch_address?
    end
  end
end
