require 'test_helper'

class ListingsHelperTest < ActionView::TestCase
  include ListingsHelper

  context '#space_listing_placeholder_path' do
    should "return valid placeholder from filesystem" do
      expected_path = "placeholders/410x254.gif"
      assert_equal expected_path, space_listing_placeholder_path(height: 254, width: 410)
    end

    should "return valid placeholder from placehold.it" do
      expected_path = "http://placehold.it/10x700&text=Photos+Unavailable"
      assert_equal expected_path, space_listing_placeholder_path(height: 700, width: 10)
    end
  end

  context '#connection_tooltip_for' do
    should 'return joined arrray of connections' do
      tooltip = connection_tooltip_for(['con1', 'con2'])
      assert_equal 'con1<br />con2', tooltip
    end

    should 'return only limited count with text' do
      cons = ['con1', 'con2', 'con3', 'con4', 'con5', 'con6']
      tooltip = connection_tooltip_for(cons)
      expected = 'con1<br />con2<br />con3<br />con4<br />con5<br />Plus one more connection'
      assert_equal expected, tooltip
    end
  end
end
