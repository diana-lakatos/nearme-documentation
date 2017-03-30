# frozen_string_literal: true
require 'test_helper_lite'
require './lib/elastic/aggregations'
require './lib/elastic/aggregations/options_for_select'
require './test/unit/lib/elastic/fixtures'
require 'pry'
require 'ostruct'

class Elastic::AggregationsTest < ActiveSupport::TestCase
  test 'require default aggregations' do
    fixtures = AggregationsFixtures.load

    assert_equal fixtures.keys, %w(global filtered_aggregations custom_attributes)

    options = Elastic::Aggregations::OptionsForSelect.prepare(fixtures)

    assert_includes options.keys, 'designer_name'
    assert_includes options.keys, 'color'

    assert_equal options.fetch('color').size, 12
    # heavily based on fixtures
    assert_equal options.fetch('color').map(&:value), [12, 4, 4, 3, 0, 0, 0, 2, 2, 1, 1, 1]
  end
end
