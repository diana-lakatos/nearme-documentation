# encoding: UTF-8
# above comment is required to display euro symbol correctly!
require 'test_helper'
require 'action_view/test_case'

class CurrencyHelperTest < ActionView::TestCase
  test 'number to currency symbol for dollars' do
    assert_equal wrap_with_span_with_tooltip("$10.00", 'USD'), number_to_currency_symbol('USD', 10)
  end

  test 'number to currency symbol for default value' do
    assert_equal wrap_with_span_with_tooltip("$0.00", 'USD'), number_to_currency_symbol('USD')
  end

  test 'number to currency symbol for euro' do
    assert_equal wrap_with_span_with_tooltip("€10.00", 'EUR'), number_to_currency_symbol('EUR', 10)
  end

  test 'number to currency symbol for canadian dollars' do
    assert_equal wrap_with_span_with_tooltip("$10.00", 'CAD'), number_to_currency_symbol('CAD', 10)
  end

  private 
  def wrap_with_span_with_tooltip(text, unit)
    "<span rel=\"tooltip\" title=\"#{unit}\">#{text}</span>"
  end
end
