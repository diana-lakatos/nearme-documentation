require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    stub_request(:get, /.*api\.mixpanel\.com.*/)
    @tracker = Analytics::EventTracker.any_instance
  end

  should "track search" do
    @tracker.expects(:conducted_a_search)
    get :index
  end

end

