# frozen_string_literal: true
require 'test_helper_lite'
require './lib/liquid/filters/platform_filters'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/string/output_safety'

class Liquid::Filters::PlatformFiltersTest < ActiveSupport::TestCase
  class Template
    include Liquid::Filters::PlatformFilters
  end

  def filters
    @template ||= Template.new
  end

  test 'map_attributes' do
    items = [{ 'id' => 1, 'name' => 'foo', 'label' => 'Foo' }, { 'id' => 2, 'name' => 'bar', 'label' => 'Bar' }]
    assert_equal [[1, 'foo'], [2, 'bar']], filters.map_attributes(items, 'id', 'name')
  end

  test 'translate' do
    I18n.backend.store_translations(:en, foo: 'bar')
    translated = filters.translate('foo')

    assert_equal 'bar', translated
    assert_equal 'bar<small>zoo</small>', ERB::Util.html_escape(translated + '<small>zoo</small>'.html_safe)
  end
end
