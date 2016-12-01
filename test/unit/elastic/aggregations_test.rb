require 'test_helper_lite'
require 'ostruct'
require './lib/elastic/aggregations'
require './lib/elastic/aggregations/base_aggregator'
require './lib/elastic/aggregations/default_aggregator'
require './lib/elastic/aggregations/builder'
require './lib/elastic/aggregations/aggregator'
require './lib/elastic/aggregations/field'
require 'pry'

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
      { label: :color, field: 'custom_attributes.color' },
      { label: :designer_name, field: 'custom_attributes.designer_name' }
    ]

    builder = Elastic::Aggregations::Builder.new
    builder.add name: :custom_attrs, fields: definitions, filters: { some: 'filters'}

    assert_includes builder.body.keys, :custom_attrs, 'has custom_attrs hey'
    assert_not_includes builder.body.keys, :filtered_aggregations

    # assert builder.body.dig(:custom_attrs, :global)
    assert_equal builder.body.dig(:custom_attrs, :aggregations).keys, [:color, :designer_name]
    assert_equal builder.body.dig(:custom_attrs, :aggregations, :color), terms: { field: 'custom_attributes.color', size: 25 }
    assert_equal builder.body.dig(:custom_attrs, :aggregations, :designer_name), terms: { field: 'custom_attributes.designer_name', size: 25 }
  end
end
