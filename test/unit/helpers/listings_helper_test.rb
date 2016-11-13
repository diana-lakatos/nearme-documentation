# frozen_string_literal: true
require 'test_helper'
require Rails.root.join 'test/helpers/placeholder_helper'
include PlaceholderHelper

class ListingsHelperTest < ActionView::TestCase
  include ListingsHelper
  include PlaceholderHelper

  context '#space_listing_placeholder_path' do
    should 'return valid placeholder' do
      assert_equal placeholder_url(410, 254), space_listing_placeholder_path(width: 410, height: 254)
    end
  end

  context '#connection_tooltip_for' do
    should 'return joined arrray of connections' do
      tooltip = connection_tooltip_for(%w(con1 con2))
      assert_equal 'con1<br />con2', tooltip
    end

    should 'return only limited count with text' do
      cons = %w(con1 con2 con3 con4 con5 con6)
      tooltip = connection_tooltip_for(cons)
      expected = 'con1<br />con2<br />con3<br />con4<br />con5<br />Plus one more connection'
      assert_equal expected, tooltip
    end
  end
end
