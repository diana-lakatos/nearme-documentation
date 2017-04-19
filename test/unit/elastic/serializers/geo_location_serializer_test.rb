require 'test_helper_lite'
require 'active_model'
require 'ostruct'
require 'pry'
require 'active_model_serializers'
require './app/serializers/elastic_indexer/geo_service_shape_serializer.rb'
require './app/serializers/elastic_indexer/geo_location_serializer.rb'

class ElasticIndexer::GeoServiceShapeSerializerTest < ActiveSupport::TestCase
  test 'names are correct' do
    current_address = OpenStruct.new(longitude: 150, latitude: -33)
    profile = OpenStruct.new(properties: {'service_radius' => '25km'})
    user = OpenStruct.new(current_address: current_address, seller_profile: profile)

    json = ElasticIndexer::GeoServiceShapeSerializer.new(user).as_json

    assert_equal json.dig(:coordinates, 0), current_address.longitude
    assert_equal json.dig(:coordinates, 1), current_address.latitude
    assert_equal json.dig(:type), 'circle'
    assert_equal json.dig(:radius), '25km'
  end

  test 'names are correct when location are null' do
    current_address = OpenStruct.new(longitude: nil, latitude: nil)
    user = OpenStruct.new(current_address: current_address)

    json = ElasticIndexer::GeoServiceShapeSerializer.new(user).as_json

    assert_nil json
  end

  test 'names are correct when no current_address' do
    user = OpenStruct.new(current_address: nil)

    json = ElasticIndexer::GeoServiceShapeSerializer.new(user).as_json

    assert_nil json
  end
end

class ElasticIndexer::GeoLocationSerializerTest < ActiveSupport::TestCase
  test 'names are correct when current_address exists' do
    current_address = OpenStruct.new(longitude: 150, latitude: -33)
    user = OpenStruct.new(current_address: current_address)

    json = ElasticIndexer::GeoLocationSerializer.new(user).as_json

    assert_equal json.dig(:lon), current_address.longitude
    assert_equal json.dig(:lat), current_address.latitude
  end

  test 'names are correct when lan is nul' do
    current_address = OpenStruct.new(longitude: nil, latitude: nil)
    user = OpenStruct.new(current_address: current_address)

    json = ElasticIndexer::GeoLocationSerializer.new(user).as_json

    assert_nil json
  end

  test 'names are correct when no current_address' do
    user = OpenStruct.new(current_address: nil)

    json = ElasticIndexer::GeoLocationSerializer.new(user).as_json

    assert_nil json
  end
end
