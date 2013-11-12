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

  context '#connection_*_for' do
    setup do
      @listing = stub
      @current_user = stub
      expects(:connections_for).with(@listing, @current_user).returns(['con1', 'con2']).once
    end

    context '#connection_count_for' do
      should 'return connections count' do
        count = connection_count_for(@listing, @current_user)
        assert_equal 2, count
      end
    end

    context '#connection_tooltip_for' do
      should 'return joined arrray of connections' do
        tooltip = connection_tooltip_for(@listing, @current_user)
        assert_equal 'con1<br />con2', tooltip
      end
    end
  end
end
