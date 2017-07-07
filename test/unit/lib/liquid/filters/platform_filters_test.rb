# frozen_string_literal: true
require 'test_helper_lite'
require './lib/liquid/filters/platform_filters'

class Liquid::Filters::PlatformFiltersTest < ActiveSupport::TestCase
  class Template
    include Liquid::Filters::PlatformFilters
  end

  def filter
    @template ||= Template.new
  end

  test 'map_attributes' do
    items = [{ 'id' => 1, 'name' => 'foo', 'label' => 'Foo' }, { 'id' => 2, 'name' => 'bar', 'label' => 'Bar' }]
    assert_equal [[1, 'foo'], [2, 'bar']], filter.map_attributes(items, 'id', 'name')
  end
end
