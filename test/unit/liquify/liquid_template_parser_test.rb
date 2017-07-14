# frozen_string_literal: true
require 'test_helper_lite'
require 'pry'
require 'liquid'
require './app/helpers/attributes_parser_helper'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/keys'
require 'active_support/testing/assertions'
require './lib/liquify/liquid_template_parser'

module Liquify
  class ErrorLogger
    @@errors = []

    def self.error(type, message, options)
      @@errors << [type, message]
    end

    def self.errors
      @@errors
    end
  end

  class TitleTag < Liquid::Tag
    include AttributesParserHelper

    def initialize(tag_name, title, tokens)
      super
      @title = title
    end

    def render(context)
      @title.bar
    end
  end

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
      result = nil

      assert_difference -> { ErrorLogger.errors.size } do
        result = parser.parse(source, data)
      end

      assert_equal 'Liquid Error', result
      assert_equal ['Liquid Error', "Liquid syntax error: Unknown tag 'foo'"], ErrorLogger.errors.last
    end

    test 'log runtime error' do
      source = '{{ aaa | date }}'
      data = {}

      parser = LiquidTemplateParser.new(filters: [], logger: ErrorLogger, raise_mode: false, default_data: {})
      result = nil

      assert_difference -> { ErrorLogger.errors.size } do
        result = parser.parse(source, data)
      end

      assert_equal 'Liquid error: wrong number of arguments (given 1, expected 2)', result
      assert_equal ['Liquid Error', 'Liquid error: wrong number of arguments (given 1, expected 2)'], ErrorLogger.errors.last
    end

    test 'log runtime error from custom tag' do
      Liquid::Template.register_tag('title', TitleTag)
      source = "{% assign foo = 'bar' %}{% title foo %}"
      data = {}

      parser = LiquidTemplateParser.new(filters: [], logger: ErrorLogger, raise_mode: false, default_data: {})
      result = nil

      assert_difference -> { ErrorLogger.errors.size } do
        result = parser.parse(source, data)
      end

      assert_equal 'Liquid error: internal', result
      assert_equal ['Liquid Error', "undefined method `bar' for \"foo \":String"], ErrorLogger.errors.last
    end
  end
end
