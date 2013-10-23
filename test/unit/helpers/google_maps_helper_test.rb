require 'test_helper'

class GoogleMapsHelperTest < ActionView::TestCase
  include GoogleMapsHelper

  context '#google_maps_route_url' do
    should 'return valid url' do
      url = "//maps.google.com/?daddr=Frisco&saddr=Cali"
      assert_equal url, google_maps_route_url(from: 'Cali', to: 'Frisco')
    end
  end
end
