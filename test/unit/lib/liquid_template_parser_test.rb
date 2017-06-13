# frozen_string_literal: true
class ErrorLogger
  def self.error(type, message, options)
  end
end

require 'test_helper_lite'
require 'liquid'
require 'active_support/core_ext/hash/keys'
require './lib/liquid_template_parser'

class LiquidTemplateParserTest < ActiveSupport::TestCase
  test 'render' do
    source = '{{ foo }}'
    data = { foo: 'bar' }

    parser = LiquidTemplateParser.new(filters: [], logger: nil, raise_mode: false, default_data: {})

    assert_equal 'bar', parser.parse(source, data)
  end

  test 'log error' do
    source = '{% foo %}}'
    data = {}

    parser = LiquidTemplateParser.new(filters: [], logger: ErrorLogger, raise_mode: false, default_data: {})

    assert_equal 'Liquid Error', parser.parse(source, data)
  end
end
