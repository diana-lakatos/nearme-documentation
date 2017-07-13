# frozen_string_literal: true
require 'test_helper_lite'
require 'elasticsearch'
require 'elasticsearch/model'
require 'graphql'
require 'hashie/mash'

require './lib/elastic/configuration'
require './lib/elastic/source_types'
require './lib/elastic/query_builder/franco'
require './lib/elastic/query_builder/collection'
require './lib/elastic/query_builder/fletcher'

require_relative './dependencies'
require_relative './utils'

require 'benchmark'

Elastic::Configuration.set(type: :default, instance_id: 1)

module Graph
  module Types
    module Listings
      class ListingQueryTest < ActiveSupport::TestCase
        test 'UOT setup' do
          ES.around(instance_name: 'uot') do |graph|
            # ask ES directly
            assert_equal  40, ES.search(query: '*', type: '').dig('hits', 'total')
            assert_equal  20, ES.search(query: '*', type: 'user').dig('hits', 'total')
            assert_equal  20, ES.search(query: '*', type: 'transactable').dig('hits', 'total')

            assert_equal  1, ES.search(query: 'Darcus Grill', type: 'user').dig('hits', 'total')
            assert_equal  10, ES.search(query: 'Test for SME decline', type: 'user').dig('hits', 'total')

            graph.execute(:projects, 'per_page' => 20, 'page' => 1).tap do |results|
              assert_equal 'darcus-grill', results.dig('data', 'projects', 'results', 5, 'project_owner', 'slug')
              assert_equal '0.0', results.dig('data', 'projects', 'results', 0, 'budget')
              assert_equal '0.0', results.dig('data', 'projects', 'results', 1, 'budget')
              assert_equal '0.0', results.dig('data', 'projects', 'results', 2, 'budget')
              assert_equal '14h', results.dig('data', 'projects', 'results', 0, 'estimation')
            end

            # paging
            graph.execute(:experts, 'per_page' => 40, 'page' => 1).tap do |results|
              assert_equal 20, results.dig('data', 'experts', 'total_entries')
              assert_equal false, results.dig('data', 'experts', 'has_next_page')
              assert_equal false, results.dig('data', 'experts', 'has_previous_page')
            end

            graph.execute(:experts, 'per_page' => 10, 'page' => 1).tap do |results|
              assert_equal 20, results.dig('data', 'experts', 'total_entries')
              assert_equal 10, results.dig('data', 'experts', 'size')
              assert_equal true, results.dig('data', 'experts', 'has_next_page')
              assert_equal false, results.dig('data', 'experts', 'has_previous_page')
            end

            graph.execute(:experts, 'per_page' => 10, 'page' => 2).tap do |results|
              assert_equal 20, results.dig('data', 'experts', 'total_entries')
              assert_equal 10, results.dig('data', 'experts', 'size')
              assert_equal false, results.dig('data', 'experts', 'has_next_page')
              assert_equal true, results.dig('data', 'experts', 'has_previous_page')
            end

            graph.execute(:experts, 'per_page' => 10, 'page' => 3).tap do |results|
              assert_equal 20, results.dig('data', 'experts', 'total_entries')
              assert_equal 0, results.dig('data', 'experts', 'size')
              assert_equal false, results.dig('data', 'experts', 'has_next_page')
              assert_equal true, results.dig('data', 'experts', 'has_previous_page')
            end

            graph.execute(:experts, 'per_page' => 6, 'page' => 2).tap do |results|
              assert_equal 20, results.dig('data', 'experts', 'total_entries')
              assert_equal 6, results.dig('data', 'experts', 'size')
              assert_equal true, results.dig('data', 'experts', 'has_next_page')
              assert_equal true, results.dig('data', 'experts', 'has_previous_page')
            end

            graph.execute(:experts, 'per_page' => 6, 'page' => 3).tap do |results|
              assert_equal 20, results.dig('data', 'experts', 'total_entries')
              assert_equal 6, results.dig('data', 'experts', 'size')
              assert_equal true, results.dig('data', 'experts', 'has_next_page')
              assert_equal true, results.dig('data', 'experts', 'has_previous_page')
            end

            graph.execute(:experts, 'per_page' => 6, 'page' => 4).tap do |results|
              assert_equal 20, results.dig('data', 'experts', 'total_entries')
              assert_equal 2, results.dig('data', 'experts', 'size')
              assert_equal false, results.dig('data', 'experts', 'has_next_page')
              assert_equal true, results.dig('data', 'experts', 'has_previous_page')
            end

            graph.execute(:experts, 'per_page' => 20, 'page' => 1).tap do |results|
              assert_equal 20, results.dig('data', 'experts', 'total_entries')
            end

            # TAGS searchable by name and by slug
            graph.execute(:experts, 'tags' => ['creative director mustash']).tap do |results|
              assert_equal 1, results.dig('data', 'experts', 'total_entries')
            end

            graph.execute(:experts, 'tags' => ['creative-director-mustash']).tap do |results|
              assert_equal 1, results.dig('data', 'experts', 'total_entries')
            end

            graph.execute(:experts, 'tags' => %w(manager accessible)).tap do |results|
              assert_equal 5, results.dig('data', 'experts', 'total_entries')
            end

            # fetch categories
            graph.execute(:experts, 'tags' => %w(manager accessible)).tap do |results|
              assert_equal 'Technology', results.dig('data', 'experts', 'results', 0, 'buyer_profile', 'industries', 0, 'name')
              assert_equal 'English', results.dig('data', 'experts', 'results', 0, 'buyer_profile', 'languages', 0, 'name')
            end

            # filter by profile categories
            graph.execute(:experts, 'category_ids' => [7222]).tap do |results|
              assert_equal 1, results.dig('data', 'experts', 'total_entries')
              assert_equal 'Korean', results.dig('data', 'experts', 'results', 0, 'default_profile', 'languages', 0, 'name')
            end

            # filter by property
            graph.execute(:experts, 'workplace_types' => ['On Site']).tap do |results|
              assert_equal 6, results.dig('data', 'experts', 'total_entries')
            end

            # is_deleted
            graph.execute(:experts, 'is_deleted' => true).tap do |results|
              assert_equal 5, results.dig('data', 'experts', 'total_entries')
            end

            # is_deleted
            graph.execute(:experts, 'is_deleted' => false).tap do |results|
              assert_equal 15, results.dig('data', 'experts', 'total_entries')
            end

            graph.execute(:experts, 'is_deleted' => false, 'query' => 'Business Intelligence (BI)').tap do |results|
              assert_equal 1, results.dig('data', 'experts', 'total_entries')
            end

            graph.execute(:experts, 'per_page' => 10, 'city' => 'Clearwater', 'page' => 1).tap do |results|
              assert_equal 1, results.dig('data', 'experts', 'total_entries'), 1
              assert_equal 'Online', results.dig('data', 'experts', 'results', 0, 'buyer_profile', 'workplace_type', 0)
              assert_equal 'On Site', results.dig('data', 'experts', 'results', 0, 'buyer_profile', 'workplace_type', 1)
            end

            graph.execute(:experts, 'per_page' => 10, 'page' => 1, 'enabled' => true, 'profile_field_sort' => 'properties.hourly_rate', 'profile_type' => 'buyer').tap do |results|
              assert_equal %w(1 2 3 5 6 7 8 11 13 15),
                           results.dig('data', 'experts', 'results').map { |r| r['buyer_profile']['hourly_rate'] }
            end

            graph.execute(:experts, 'per_page' => 10, 'page' => 1, 'profile_field_sort' => 'properties.hourly_rate', 'profile_type' => 'buyer', 'order' => 'desc').tap do |results|
              assert_equal %w(15 13 12 11 10 9 8 7 6 5), results.dig('data', 'experts', 'results').map { |r| r['buyer_profile']['hourly_rate'] }
            end

            graph.execute(:experts, 'per_page' => 10, 'page' => 1, 'sort' => 'current_address.city', 'order' => 'asc').tap do |results|
              assert_equal ['Allen', 'Asheville', 'Blackpool', 'Carlsbad', 'Clearwater', 'Colorado Springs', 'Fayetteville', 'Kirkland', 'Minneapolis', 'Overland Park'],
                           results.dig('data', 'experts', 'results').map { |r| r.dig('address', 'city') }.uniq
            end
          end
        end
      end
    end
  end
end
