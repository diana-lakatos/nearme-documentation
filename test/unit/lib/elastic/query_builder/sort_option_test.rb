# frozen_string_literal: true
require 'test_helper_lite'
require 'ostruct'
require './lib/elastic/query_builder_base'
require './lib/elastic/query_builder/users_query_builder'
require './lib/elastic/query_builder/sorting_options'

class Elastic::QueryBuilder::SortingOptions::SortOptionTest < ActiveSupport::TestCase

  def build(*args)
    Elastic::QueryBuilder::SortingOptions::SortOption.new(*args)
  end

  def assert_equal_sort(key, expectation)
    assert_equal build(key).to_h.dig(:sort, 0), expectation
  end

  test 'user_profiles.seller.date_of_birth_desc' do
    assert_equal_sort 'user_profiles.seller.properties.date_of_birth_desc', 'user_profiles.properties.date_of_birth' => { order: 'desc', nested_path: 'user_profiles', nested_filter: { term: { 'user_profiles.profile_type' => 'seller'}}}
  end

  test 'user_profiles.default.some_property_desc' do
    assert_equal_sort 'user_profiles.default.properties.some_property_desc', 'user_profiles.properties.some_property' => { order: 'desc', nested_path: 'user_profiles', nested_filter: { term: { 'user_profiles.profile_type' => 'default'}}}
  end

  test 'custom_attribute.some_seller_property_asc' do
    assert_equal_sort 'user_profiles.seller.properties.some_seller_property_asc', 'user_profiles.properties.some_seller_property' => { order: 'asc', nested_path: 'user_profiles', nested_filter: { term: { 'user_profiles.profile_type' => 'seller'}}}
  end

  test 'seller_average_rating_asc' do
    assert_equal_sort 'seller_average_rating_asc', 'seller_average_rating' => 'asc'
  end

  test 'user.seller_average_rating_asc' do
    assert_equal_sort 'seller_average_rating_asc', 'seller_average_rating' => 'asc'
  end

  test 'transactable.price_asc' do
    build('transactable.custom_attributes.all_prices_asc').tap do |query|
      assert_equal query.to_h.dig(:sort, 0), {'_score' => 'asc'}
    end
  end
end

class Elastic::QueryBuilder::SortingOptions::SortOption::NestedSortTest < ActiveSupport::TestCase

  def build(*args)
    Elastic::QueryBuilder::SortingOptions::SortOption::NestedSort.new(*args)
  end

  test 'nested' do
    field = build(name: 'date_of_birth', order: 'asc', profile_type: 'seller')

    assert_equal field.to_h.dig(:sort, 0), 'user_profiles.properties.date_of_birth' => { order: 'asc', nested_path: 'user_profiles', nested_filter: { term: { 'user_profiles.profile_type' => 'seller'}}}
  end
end

class Elastic::QueryBuilder::SortingOptions::SortOption::SimpleSortTest < ActiveSupport::TestCase

  def build(*args)
    Elastic::QueryBuilder::SortingOptions::SortOption::SimpleSort.new(*args)
  end

  test 'simple' do
    field = build(name: 'date_of_birth', order: 'asc')

    assert_equal field.to_h.dig(:sort, 0), 'date_of_birth' => 'asc'
  end
end

class Elastic::QueryBuilder::SortingOptions::SortOption::ChildFieldSortTest < ActiveSupport::TestCase

  def build(*args)
    Elastic::QueryBuilder::SortingOptions::SortOption::ChildFieldSort.new(*args)
  end

  test 'simple' do
    field = build(name: 'all_prices', order: 'asc', type: 'doc_type')

    assert_equal field.to_h,
                 query: {
                   bool: {
                     must: [
                       has_child: {
                         inner_hits: { _source: '*' },
                         type: 'doc_type',
                         score_mode: 'max',
                         query: {
                           function_score: { script_score: { script: '_score * doc["all_prices"].values[0]'}}
                         }
                       }

                     ]
                   }
                 },
                 sort: [{ '_score' => 'asc' }]
  end
end
