# frozen_string_literal: true
require 'test_helper_lite'
require 'ostruct'
require './lib/elastic/aggregations'
require './lib/elastic/aggregations/base_aggregator'
require './lib/elastic/aggregations/default_aggregator'
require './lib/elastic/aggregations/builder'
require './lib/elastic/aggregations/aggregator'
require './lib/elastic/aggregations/nodes'
require 'pry'
require 'json'

class Elastic::AggregationsTest < ActiveSupport::TestCase
  test 'prepare required default aggregations' do
    builder = Elastic::Aggregations::Builder.new

    builder.add_default filters: { rule: true }
    assert_includes builder.body.keys, :filtered_aggregations

    builder.add_default name: :other_name, filters: { rule: true }
    assert_includes builder.body.keys, :other_name

    assert_equal builder.body.dig(:filtered_aggregations, :aggregations).keys, [:distinct_locations, :maximum_price, :minimum_price]
    assert_equal builder.body.dig(:filtered_aggregations, :aggregations, :distinct_locations).keys, [:cardinality]
    assert_equal builder.body.dig(:filtered_aggregations, :aggregations, :maximum_price).keys, [:max]
    assert_equal builder.body.dig(:filtered_aggregations, :aggregations, :minimum_price).keys, [:min]

    assert_equal builder.body.dig(:filtered_aggregations, :aggregations, :minimum_price), min: { field: :all_prices }
  end

  test 'prepare required custom-attrs aggregations' do
    definitions = [
      { label: :color, field: 'custom_attributes.color', size: 25 },
      { label: :designer_name, field: 'custom_attributes.designer_name', size: 25 }
    ]

    builder = Elastic::Aggregations::Builder.new
    builder.add name: :custom_attrs, fields: definitions, filters: { some: 'filters' }

    assert_includes builder.body.keys, :custom_attrs, 'has custom_attrs hey'
    assert_not_includes builder.body.keys, :filtered_aggregations

    # assert builder.body.dig(:custom_attrs, :global)
    assert_equal builder.body.dig(:custom_attrs, :aggregations).keys, [:color, :designer_name]
    assert_equal builder.body.dig(:custom_attrs, :aggregations, :color), terms: { field: 'custom_attributes.color', size: 25, order: { _term: 'asc' } }
    assert_equal builder.body.dig(:custom_attrs, :aggregations, :designer_name), terms: { field: 'custom_attributes.designer_name', size: 25, order: { _term: 'asc' } }
  end

  test 'prepare nested aggregations for user-profiles using fields' do
    builder = Elastic::Aggregations::Nodes::Node.new label: :aggregations

    nested = Elastic::Aggregations::Nodes::Nested.new(label: 'user_profiles', path: 'user_profiles')
    profiles = Elastic::Aggregations::Nodes::Terms.new(label: 'profile_type', field: 'user_profiles.profile_type')
    properties = Elastic::Aggregations::Nodes::Terms.new(label: 'states', field: 'user_profiles.properties.state.raw', size: 52, order: { _term: 'asc' })

    profiles.add_field properties
    nested.add_field profiles
    builder.add_field nested

    assert_equal builder.to_h.dig(:aggregations, 'user_profiles', :aggregations).keys, ['profile_type']
    assert_equal builder.to_h.dig(:aggregations, 'user_profiles', :nested), path: 'user_profiles'
    assert builder.to_h.dig(:aggregations, 'user_profiles', :aggregations, 'profile_type', :terms)
    assert builder.to_h.dig(:aggregations, 'user_profiles', :aggregations, 'profile_type', :aggregations)
    assert builder.to_h.dig(:aggregations, 'user_profiles', :aggregations, 'profile_type', :aggregations, 'states')
    assert builder.to_h.dig(:aggregations, 'user_profiles', :aggregations, 'profile_type', :aggregations, 'states', :terms, :field)
  end

  test 'prepare nested aggregations for user-profiles using fancy block method' do
    builder = Elastic::Aggregations::Nodes::Node.new label: :aggregations do |root|
      root.add :nested, label: 'user_profiles', path: 'user_profiles' do |nested|
        nested.add :terms, label: 'profile_type', field: 'user_profiles.profile_type' do |profiles|
          profiles.add :terms, label: 'states', field: 'user_profiles.properties.state.raw', size: 52, order: { _term: 'asc' }
        end
      end
    end

    # "aggregations": {
    #     "user_profiles": {
    #       "nested": { "path": "user_profiles" },
    #       "aggregations": {
    #         "profile_type": {
    #           "terms": { "field": "user_profiles.profile_type" },
    #           "aggregations": {
    #             "states": {
    #               "terms": {
    #                 "field": "user_profiles.properties.states.raw",
    #                 "size": 52,
    #                 "order": {"_term": "asc"}}}}
    #         }
    #       }
    #     }
    #   }

    assert_equal builder.to_h.dig(:aggregations, 'user_profiles', :aggregations).keys, ['profile_type']
    assert_equal builder.to_h.dig(:aggregations, 'user_profiles', :nested), path: 'user_profiles'
    assert builder.to_h.dig(:aggregations, 'user_profiles', :aggregations, 'profile_type', :terms)
    assert builder.to_h.dig(:aggregations, 'user_profiles', :aggregations, 'profile_type', :aggregations)
    assert builder.to_h.dig(:aggregations, 'user_profiles', :aggregations, 'profile_type', :aggregations, 'states')
    assert builder.to_h.dig(:aggregations, 'user_profiles', :aggregations, 'profile_type', :aggregations, 'states', :terms, :field)
  end
end
