# encoding: UTF-8
# above comment is required to display euro symbol correctly!
require 'test_helper'
require 'action_view/test_case'

class ApplicationHelperTest < ActionView::TestCase
  test 'number to currency symbol for dollars' do
    assert_equal wrap_with_span_with_tooltip("$10.00", 'USD'), number_to_currency_symbol(10, {:unit => 'USD'})
  end

  test 'number to currency symbol for default value' do
    assert_equal wrap_with_span_with_tooltip("$10.00", 'USD'), number_to_currency_symbol(10)
  end

  test 'number to currency symbol for euro' do
    assert_equal wrap_with_span_with_tooltip("€10.00", 'EUR'), number_to_currency_symbol(10, {:unit => 'EUR'})
  end

  test 'number to currency symbol for canadian dollars' do
    assert_equal wrap_with_span_with_tooltip("$10.00", 'CAD'), number_to_currency_symbol(10, {:unit => 'CAD'})
  end

  private 
  def wrap_with_span_with_tooltip(text, unit)
    "<span rel=\"tooltip\" title=\"#{unit}\">#{text}</span>"
  end
end
