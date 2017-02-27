require 'test_helper'

class Location::SerializationTest < ActiveSupport::TestCase
  context 'a location with no listing should have all the default attributes' do
    setup do
      @location = FactoryGirl.create(:location_in_san_francisco)
      serialize
    end

    should 'have an id' do
      assert_equal @location.id, @json[:id]
    end

    should 'have a name' do
      assert_equal @location.name, @json[:name]
    end

    should 'have a description' do
      assert_equal @location.description, @json[:description]
    end

    should 'have an email' do
      assert_equal @location.email, @json[:email]
    end

    should 'have a phone' do
      assert_equal @location.phone, @json[:phone]
    end

    should 'have a latitude' do
      assert_equal @location.latitude, @json[:latitude]
    end

    should 'have a longitude' do
      assert_equal @location.longitude, @json[:longitude]
    end

    should 'have a location_type_id' do
      assert_equal @location.location_type_id, @json[:location_type_id]
    end

    should 'have an availability_template_id' do
      assert_equal @location.availability_template_id, @json[:availability_template_id]
    end

    should 'have 7 availability rules defined' do
      assert_equal 7, @json[:availability_rules_attributes].count
    end

    should 'have no listings' do
      assert @json[:listings].empty?
    end
  end

  context 'a location with listings' do
    setup do
      @location = FactoryGirl.create(:location_in_san_francisco)
    end

    context ' 1 listing' do
      setup do
        setup_listing_with 1
        serialize
      end
      should 'have 1 listings' do
        assert_equal 1, @json[:listings].count
      end
    end

    context ' multiple listings' do
      setup do
        setup_listing_with 2
        serialize
      end
      should 'have 2 listings' do
        assert_equal 2, @json[:listings].count
      end
    end
  end

  def setup_listing_with(listing_number)
    FactoryGirl.create_list(:transactable, listing_number, :with_time_based_booking, location: @location)
    @location.reload
  end

  def serialize
    @serializer = LocationSerializer.new(@location)
    @json = @serializer.as_json[:location]
  end
end
