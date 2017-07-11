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
        test 'ATB setup' do
          ES.around(instance_name: 'atb') do |graph|
            graph.execute(:projects, 'per_page' => 20, 'page' => 1, 'customization_name' => "gig_invitation", "customization_user_id" => 123, "creator_id" => 1111, "state" => "pending").tap do |results|
              assert_equal 2, results.dig('data', 'projects', 'total_entries')
              assert_equal 'gig_invitation', results.dig('data', 'projects', 'results', 0, 'customizations', 0, 'name')
              assert_equal 'Gig Invitation', results.dig('data', 'projects', 'results', 0, 'customizations', 0, 'human_name')
              assert_equal 1, results.dig('data', 'projects', 'results', 0, 'customizations').size
              assert_equal 1, results.dig('data', 'projects', 'results', 1, 'customizations').size
            end

            graph.execute(:projects, 'per_page' => 20, 'page' => 1, 'customization_id' => 50).tap do |results|
              assert_equal 1, results.dig('data', 'projects', 'total_entries')
              assert_equal 1, results.dig('data', 'projects', 'results', 0, 'customizations').size
              assert_equal 'gig_invitation', results.dig('data', 'projects', 'results', 0, 'customizations', 0, 'name')
            end

            graph.execute(:projects, 'per_page' => 20, 'page' => 1, 'customization_name' => "gig_invitation", "customization_user_id" => 123, "creator_id" => 1111, "state" => "in_progress").tap do |results|
              assert_equal 0, results.dig('data', 'projects', 'total_entries')
            end

            graph.execute(:projects, 'per_page' => 20, 'page' => 1, 'customization_name' => "gig_invitation", "customization_user_id" => 123, "creator_id" => 555, "state" => "in_progress").tap do |results|
              assert_equal 0, results.dig('data', 'projects', 'total_entries')
            end
          end
        end

        test 'SPACER setup' do
          ES.around(instance_name: 'spacer') do |graph|
            # ask ES directly
            assert_equal  10, ES.search(query: 'Haymarket').dig('hits', 'total')
            assert_equal  11, ES.search(query: '*', type: '').dig('hits', 'total')
            assert_equal 1, ES.search(query: 'Unique').dig('hits', 'total')

            graph.execute(:listings, 'per_page' => 20, 'page' => 1).tap do |results|
              assert_equal 'jash-kivatcheck--2', results.dig('data', 'listings', 'results', 5, 'creator', 'slug')
              assert_equal 'Basement', results.dig('data', 'listings', 'results', 0, 'storage_types', 0, 'name')
              assert_equal 'Parking Space', results.dig('data', 'listings', 'results', 0, 'storage_types', 1, 'name')
            end

            graph.execute(:listings, 'per_page' => 20, 'page' => 1).tap do |results|
              assert_equal 10, results.dig('data', 'listings', 'total_entries')
            end

            # by category name
            graph.execute(:listings, 'per_page' => 20, 'page' => 1, 'storage_types' => ['Basement']).tap do |results|
              assert_equal 1, results.dig('data', 'listings', 'total_entries')
            end

            # by category name
            graph.execute(:listings, 'per_page' => 20, 'page' => 1, 'storage_types' => %w(Basement Garage)).tap do |results|
              assert_equal 3, results.dig('data', 'listings', 'total_entries')
            end

            # by category name
            graph.execute(:listings, 'per_page' => 20, 'page' => 1, 'storage_types' => ['Garage'], 'security_features' => ['CCTV']).tap do |results|
              assert_equal 1, results.dig('data', 'listings', 'total_entries')
            end

            # by category name and query
            graph.execute(:listings, 'per_page' => 20, 'page' => 1, 'storage_types' => ['Parking Space'], 'security_features' => %w(CCTV Alarm), 'city' => 'Haymarket', 'query' => 'capitol square').tap do |results|
              assert_equal 1, results.dig('data', 'listings', 'total_entries')
            end

            # lister by property aka custom-attribute
            graph.execute(:listings, 'per_page' => 20, 'page' => 1, 'space_availability' => 'Available').tap do |results|
              assert_equal 7, results.dig('data', 'listings', 'total_entries')
            end

            # lister by property aka custom-attribute
            graph.execute(:listings, 'per_page' => 20, 'page' => 1, 'space_availability' => 'Unavailable').tap do |results|
              assert_equal 3, results.dig('data', 'listings', 'total_entries')
            end

            # lister by property aka custom-attribute list
            graph.execute(:listings, 'per_page' => 20, 'page' => 1, 'promo_code' => %w(GH1016 GH1116)).tap do |results|
              assert_equal 2, results.dig('data', 'listings', 'total_entries')
            end

            # query
            graph.execute(:listings, 'per_page' => 10, 'query' => 'Unique', 'page' => 1).tap do |results|
              assert_equal 1, results.dig('data', 'listings', 'total_entries')
              assert_equal '5 2.4x3', results.dig('data', 'listings', 'results', 0, 'size_of_space')
            end

            # is_deleted
            graph.execute(:listings, 'is_deleted' => true).tap do |results|
              assert_equal 3, results.dig('data', 'listings', 'total_entries')
            end

            # is_deleted
            graph.execute(:listings, 'is_deleted' => false).tap do |results|
              assert_equal 7, results.dig('data', 'listings', 'total_entries')
            end

            graph.execute(:listings, 'is_deleted' => true, 'query' => 'Haymarket').tap do |results|
              assert_equal 3, results.dig('data', 'listings', 'total_entries')
            end

            graph.execute(:listings, 'per_page' => 10, 'city' => 'Parramatta', 'page' => 1, 'is_deleted' => true).tap do |results|
              assert_equal 1, results.dig('data', 'listings', 'total_entries')
              assert_equal '1 2.5m clearance', results.dig('data', 'listings', 'results', 0, 'size_of_space')
            end

            graph.execute(:listings, 'per_page' => 10, 'city' => 'Haymarket', 'country' => 'Australia', 'page' => 1).tap do |results|
              assert_equal 8, results.dig('data', 'listings', 'total_entries')
              assert_equal '2 130 inches by 130 inches (3.3m x 3.3m)', results.dig('data', 'listings', 'results', 0, 'size_of_space')
            end

            graph.execute(:listings, 'per_page' => 10, 'city' => 'Haymarket', 'state' => 'Other Than NSW', 'country' => 'Australia', 'page' => 1).tap do |results|
              assert_equal 1, results.dig('data', 'listings', 'total_entries')
              assert_equal '5 2.4x3', results.dig('data', 'listings', 'results', 0, 'size_of_space')
            end

            graph.execute(:listings, 'per_page' => 10, 'city' => 'Haymarket', 'state' => 'New South Walezzzzz', 'country' => 'Australia', 'page' => 1).tap do |results|
              assert_equal 0, results.dig('data', 'listings', 'total_entries')
            end

            graph.execute(:listings, 'per_page' => 10, 'city' => 'Melbourne', 'country' => 'Germany', 'page' => 1).tap do |results|
              assert_equal 0, results.dig('data', 'listings', 'total_entries')
            end

            graph.execute(:listings, 'per_page' => 10, 'city' => 'Melbourne', 'street' => 'Bad Street', 'page' => 1).tap do |results|
              assert_equal 0, results.dig('data', 'listings', 'total_entries')
            end

            graph.execute(:listings, 'per_page' => 10, 'city' => 'Melbourne', 'street' => 'Little Lonsdale Street', 'page' => 1).tap do |results|
              assert_equal 1, results.dig('data', 'listings', 'total_entries')
            end

            graph.execute(:listings, 'per_page' => 10, 'city' => 'Melbourne', 'page' => 1, 'query' => 'carpark cbd').tap do |results|
              assert_equal 1, results.dig('data', 'listings', 'total_entries')
            end

            graph.execute(:listings, 'per_page' => 5, 'city' => 'Haymarket', 'country' => 'Australia', 'page' => 1).tap do |results|
              assert_equal 8, results.dig('data', 'listings', 'total_entries')
              assert_equal 5, results.dig('data', 'listings', 'results').size
              assert_equal '2 130 inches by 130 inches (3.3m x 3.3m)', results.dig('data', 'listings', 'results', 0, 'size_of_space')
              assert_equal '5 2.4x3', results.dig('data', 'listings', 'results', 3, 'size_of_space')
              assert_equal '6 SUV would fit in 6', results.dig('data', 'listings', 'results', 4, 'size_of_space')
            end

            graph.execute(:listings, 'per_page' => 4, 'city' => 'Haymarket', 'country' => 'Australia', 'page' => 2).tap do |results|
              assert_equal 8, results.dig('data', 'listings', 'total_entries')
              assert_equal 4, results.dig('data', 'listings', 'results').size
              assert_equal '6 SUV would fit in 6', results.dig('data', 'listings', 'results', 0, 'size_of_space')
            end

            graph.execute(:listings, 'per_page' => 10, 'page' => 1, 'sort' => 'properties.size_of_space').tap do |results|
              assert_equal %w(1 10 2 3 4 5 6 7 8 9), results.dig('data', 'listings', 'results').map { |r| r['size_of_space'][0, 2].strip }
            end

            graph.execute(:listings, 'per_page' => 10, 'page' => 1, 'sort' => 'properties.size_of_space', 'order' => 'desc').tap do |results|
              assert_equal %w(1 10 2 3 4 5 6 7 8 9).reverse, results.dig('data', 'listings', 'results').map { |r| r['size_of_space'][0, 2].strip }
            end

            graph.execute(:listings, 'per_page' => 10, 'page' => 1, 'sort' => 'address.city', 'order' => 'asc').tap do |results|
              assert_equal %w(Haymarket Melbourne Parramatta), results.dig('data', 'listings', 'results').map { |r| r['address']['city'] }.uniq
            end
          end
        end
      end
    end
  end
end
