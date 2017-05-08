# frozen_string_literal: true

class InstanceProfileType
end

require 'test_helper_lite'
require 'ostruct'
require './lib/elastic/query_builder_base'
require './lib/elastic/aggregations'
require './lib/elastic/query_builder/sorting_options'
require './lib/elastic/query_builder/users_query_builder'
require './lib/elastic/query_builder/user_profile_builder'
require './lib/elastic/query_builder/availability_exceptions'

class Elastic::QueryBuilder::UsersQueryBuilderTest < ActiveSupport::TestCase
  setup do
    @builder = Elastic::QueryBuilder::UsersQueryBuilder
  end

  test 'find by id' do
    query = { source: %w(name avatar), query: { terms: { _id: [1] } } }
    instance_profile_types = [OpenStruct.new(name: 'Jane')]
    results = @builder.new(query, instance_profile_types: instance_profile_types).simple_query

    assert_equal results.dig(:_source), %w(name avatar)
    results.dig(:filter, :bool, :must, 0, :nested).tap do |nested|
      assert_equal nested.dig(:path), 'user_profiles'
      assert_equal nested.dig(:query, :bool, :must, 0, :match), 'user_profiles.profile_type' => 'jane'
    end
  end

  test 'find by id for only enabled profiles' do
    query = { source: %w(name avatar), query: { terms: { _id: [1] } } }
    instance_profile_types = [OpenStruct.new(name: 'Jane', search_only_enabled_profiles?: true)]
    results = @builder.new(query, instance_profile_types: instance_profile_types).simple_query

    assert_equal results.dig(:_source), %w(name avatar)
    results.dig(:filter, :bool, :must, 0, :nested).tap do |nested|
      assert_equal nested.dig(:path), 'user_profiles'
      assert_equal nested.dig(:query, :bool, :must, 0, :match), 'user_profiles.profile_type' => 'jane'
      assert_equal nested.dig(:query, :bool, :must, 1, :match), "user_profiles.enabled": true
    end
  end
end
