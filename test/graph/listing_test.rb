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
        def simple_query
          G.execute(::Queries.listings, 'per_page' => 20, 'page' => 1, city: 'Sydney')
        end

        test 'setup' do
          ES.around do
            # ask ES directly
            assert_equal  10, ES.query(query: 'Haymarket').dig('hits', 'total')
            assert_equal  11, ES.query(query: '*', type: '').dig('hits', 'total')
            assert_equal 1, ES.query(query: 'Unique').dig('hits', 'total')

            G.execute(::Queries.listings, 'per_page' => 20, 'page' => 1).tap do |results|
              assert_equal results.dig('data', 'listings', 'results', 5, 'creator', 'slug'), 'jash-kivatcheck--2'
              assert_equal results.dig('data', 'listings', 'results', 0, 'storage_types', 0, 'name'), 'Basement'
              assert_equal results.dig('data', 'listings', 'results', 0, 'storage_types', 1, 'name'), 'Parking Space'
            end

            G.execute(::Queries.listings, 'per_page' => 20, 'page' => 1).tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 10
            end

            # by category name
            G.execute(::Queries.listings, 'per_page' => 20, 'page' => 1, 'storage_types' => ['Basement']).tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 1
            end

            # by category name
            G.execute(::Queries.listings, 'per_page' => 20, 'page' => 1, 'storage_types' => ['Basement', 'Garage']).tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 3
            end

            # by category name
            G.execute(::Queries.listings, 'per_page' => 20, 'page' => 1, 'storage_types' => ['Garage'], 'security_features' => ['CCTV']).tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 1
            end

            # by category name and query
            G.execute(::Queries.listings, 'per_page' => 20, 'page' => 1, 'storage_types' => ['Parking Space'], 'security_features' => ['CCTV', 'Alarm'], 'city' => 'Haymarket', 'query' => 'capitol square').tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 1
            end

            # lister by custom-attribute
            G.execute(::Queries.listings, 'per_page' => 20, 'page' => 1, 'space_availability' => 'Available').tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 7
            end

            # lister by custom-attribute
            G.execute(::Queries.listings, 'per_page' => 20, 'page' => 1, 'space_availability' => 'Unavailable').tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 3
            end

            # lister by custom-attribute list
            G.execute(::Queries.listings, 'per_page' => 20, 'page' => 1, 'promo_code' => ['GH1016', 'GH1116']).tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 2
            end

            # query
            G.execute(::Queries.listings, 'per_page' => 10, 'query' => 'Unique', 'page' => 1).tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 1
              assert_equal results.dig('data', 'listings', 'results', 0, 'size_of_space'), '5 2.4x3'
            end

            # is_deleted
            G.execute(::Queries.listings, 'is_deleted' => true).tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 3
            end

            # is_deleted
            G.execute(::Queries.listings, 'is_deleted' => false).tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 7
            end

            G.execute(::Queries.listings, 'is_deleted' => true, 'query' => 'Haymarket').tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 3
            end

            G.execute(::Queries.listings, 'per_page' => 10, 'city' => 'Parramatta', 'page' => 1, 'is_deleted' => true).tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 1
              assert_equal results.dig('data', 'listings', 'results', 0, 'size_of_space'), '1 2.5m clearance'
            end

            G.execute(::Queries.listings, 'per_page' => 10, 'city' => 'Haymarket', 'country' => 'Australia', 'page' => 1).tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 8
              assert_equal results.dig('data', 'listings', 'results', 0, 'size_of_space'), '2 130 inches by 130 inches (3.3m x 3.3m)'
            end

            G.execute(::Queries.listings, 'per_page' => 10, 'city' => 'Haymarket', 'state' => 'Other Than NSW', 'country' => 'Australia', 'page' => 1).tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 1
              assert_equal results.dig('data', 'listings', 'results', 0, 'size_of_space'), '5 2.4x3'
            end

            G.execute(::Queries.listings, 'per_page' => 10, 'city' => 'Haymarket', 'state' => 'New South Walezzzzz', 'country' => 'Australia', 'page' => 1).tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 0
            end

            G.execute(::Queries.listings, 'per_page' => 10, 'city' => 'Melbourne', 'country' => 'Germany', 'page' => 1).tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 0
            end

            G.execute(::Queries.listings, 'per_page' => 10, 'city' => 'Melbourne', 'street' => 'Bad Street', 'page' => 1).tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 0
            end

            G.execute(::Queries.listings, 'per_page' => 10, 'city' => 'Melbourne', 'street' => 'Little Lonsdale Street', 'page' => 1).tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 1
            end

            G.execute(::Queries.listings, 'per_page' => 10, 'city' => 'Melbourne', 'page' => 1, 'query' => 'carpark cbd').tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 1
            end

            G.execute(::Queries.listings, 'per_page' => 5, 'city' => 'Haymarket', 'country' => 'Australia', 'page' => 1).tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 8
              assert_equal results.dig('data', 'listings', 'results').size, 5
              assert_equal results.dig('data', 'listings', 'results', 0, 'size_of_space'), '2 130 inches by 130 inches (3.3m x 3.3m)'
              assert_equal results.dig('data', 'listings', 'results', 3, 'size_of_space'), '5 2.4x3'
              assert_equal results.dig('data', 'listings', 'results', 4, 'size_of_space'), '6 SUV would fit in 6'
            end

            G.execute(::Queries.listings, 'per_page' => 4, 'city' => 'Haymarket', 'country' => 'Australia', 'page' => 2).tap do |results|
              assert_equal results.dig('data', 'listings', 'total_entries'), 8
              assert_equal results.dig('data', 'listings', 'results').size, 4
              assert_equal results.dig('data', 'listings', 'results', 0, 'size_of_space'), '6 SUV would fit in 6'
            end

            G.execute(::Queries.listings, 'per_page' => 10, 'page' => 1, 'sort' => 'custom_attributes.size_of_space').tap do |results|
              assert_equal %w(1 10 2 3 4 5 6 7 8 9), results.dig('data','listings','results').map { |r| r['size_of_space'][0,2].strip }
            end

            G.execute(::Queries.listings, 'per_page' => 10, 'page' => 1, 'sort' => 'custom_attributes.size_of_space', 'order' => 'desc').tap do |results|
              assert_equal %w(1 10 2 3 4 5 6 7 8 9).reverse, results.dig('data','listings','results').map { |r| r['size_of_space'][0,2].strip }
            end

            G.execute(::Queries.listings, 'per_page' => 10, 'page' => 1, 'sort' => 'address.city', 'order' => 'asc').tap do |results|
              assert_equal %w(Haymarket Melbourne Parramatta), results.dig('data','listings','results').map { |r| r['address']['city'] }.uniq
            end
          end
        end
      end
    end
  end
end
