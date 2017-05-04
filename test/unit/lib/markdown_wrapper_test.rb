# frozen_string_literal: true
require 'test_helper_lite'
require './lib/markdown_wrapper'
require 'redcarpet'

class MarkdownWrapperTest < ActiveSupport::TestCase
  test 'render text with liquid tags' do
    text = 'Ala has a cat {% include foo, bar: under_score_var %}'

    assert_equal "<p>Ala has a cat {% include foo, bar: under_score_var %}</p>\n", MarkdownWrapper.new(text).to_html
  end
end
