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
  end
end
