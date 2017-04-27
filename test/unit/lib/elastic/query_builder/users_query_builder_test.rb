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

    assert_equal(
      {
        _source: %w(name avatar),
        query: { terms: { _id: [1] } },
        filter: { bool: { must: [{ nested: {
          path: 'user_profiles',
          query: { bool: { must: [
            { match: { "user_profiles.enabled": true } },
            { match: { 'user_profiles.profile_type' => 'jane' } }
          ] } }
                                   } }] } },

        sort: ['_score']
      },
      results
    )
  end
end
