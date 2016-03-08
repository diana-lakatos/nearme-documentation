# frozen_string_literal: true
require 'test_helper'

class GlobalAdmin::DashboardControllerTest < ActionController::TestCase
  context 'non-admin user' do
    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    context 'GET show' do
      should 'not display and redirect to home page' do
        get :show
        assert_response :redirect
        assert_redirected_to root_url
      end
    end
  end

  context 'admin user' do
    setup do
      @user = FactoryGirl.create(:user, admin: true)
      sign_in @user
    end

    context 'GET show' do
      should 'show mixpanel data' do
        Mixpanel::DataReceiver.any_instance.stubs(:get_funnel_data).with('New Listings').returns(real_new_listing_funnel_response)
        Mixpanel::DataReceiver.any_instance.stubs(:get_funnel_data).with('Booking Flow').returns(real_booking_flow_funnel_response)
        get :show
        assert_response :success
      end
    end

    context 'GET show' do
      should 'work if one or more funnels do not have data' do
        Mixpanel::DataReceiver.any_instance.stubs(:get_funnel_data).with('New Listings').returns(real_new_listing_funnel_response)
        Mixpanel::DataReceiver.any_instance.stubs(:get_funnel_data).with('Booking Flow').returns({})
        get :show
        assert_response :success
      end
    end
  end

  private

  def real_new_listing_funnel_response
    {
      'meta' => { 'property_values' => ['1'] },
      'data' => {
        '2013-08-20' => { '1' => [
          { 'count' => 70, 'step_conv_ratio' => 1, 'goal' => 'Signed Up', 'overall_conv_ratio' => 1, 'avg_time' => nil, 'event' => 'Signed Up' },
          { 'count' => 62, 'step_conv_ratio' => 0.8857142857142857, 'goal' => 'Viewed List Your First Bookable', 'overall_conv_ratio' => 0.8857142857142857, 'avg_time' => 2, 'event' => 'Viewed List Your First Bookable' },
          { 'count' => 13, 'step_conv_ratio' => 0.20967741935483872, 'goal' => 'Created a Location', 'overall_conv_ratio' => 0.18571428571428572, 'avg_time' => 1104, 'event' => 'Created a Location' },
          { 'count' => 13, 'step_conv_ratio' => 1.0, 'goal' => 'Created a Listing', 'overall_conv_ratio' => 0.18571428571428572, 'avg_time' => 0, 'event' => 'Created a Listing' }
        ],
                          '$overall' => [
                            { 'count' => 70, 'step_conv_ratio' => 1, 'avg_time' => nil, 'event' => 'Signed Up', 'overall_conv_ratio' => 1 },
                            { 'count' => 62, 'step_conv_ratio' => 0.8857142857142857, 'avg_time' => 2, 'event' => 'Viewed List Your First Bookable', 'overall_conv_ratio' => 0.8857142857142857 }, { 'count' => 13, 'step_conv_ratio' => 0.20967741935483872, 'avg_time' => 1104, 'event' => 'Created a Location', 'overall_conv_ratio' => 0.18571428571428572 },
                            { 'count' => 13, 'step_conv_ratio' => 1.0, 'avg_time' => 0, 'event' => 'Created a Listing', 'overall_conv_ratio' => 0.18571428571428572 }
                          ] },
        '2013-08-27' => { '1' => [
          { 'count' => 9, 'step_conv_ratio' => 1, 'goal' => 'Signed Up', 'overall_conv_ratio' => 1, 'avg_time' => nil, 'event' => 'Signed Up' },
          { 'count' => 9, 'step_conv_ratio' => 1.0, 'goal' => 'Viewed List Your First Bookable', 'overall_conv_ratio' => 1.0, 'avg_time' => 9, 'event' => 'Viewed List Your First Bookable' },
          { 'count' => 2, 'step_conv_ratio' => 0.2222222222222222, 'goal' => 'Created a Location', 'overall_conv_ratio' => 0.2222222222222222, 'avg_time' => 1034, 'event' => 'Created a Location' },
          { 'count' => 2, 'step_conv_ratio' => 1.0, 'goal' => 'Created a Listing', 'overall_conv_ratio' => 0.2222222222222222, 'avg_time' => 0, 'event' => 'Created a Listing' }
        ],
                          '$overall' => [
                            { 'count' => 9, 'step_conv_ratio' => 1, 'avg_time' => nil, 'event' => 'Signed Up', 'overall_conv_ratio' => 1 },
                            { 'count' => 9, 'step_conv_ratio' => 1.0, 'avg_time' => 9, 'event' => 'Viewed List Your First Bookable', 'overall_conv_ratio' => 1.0 },
                            { 'count' => 2, 'step_conv_ratio' => 0.2222222222222222, 'avg_time' => 1034, 'event' => 'Created a Location', 'overall_conv_ratio' => 0.2222222222222222 },
                            { 'count' => 2, 'step_conv_ratio' => 1.0, 'avg_time' => 0, 'event' => 'Created a Listing', 'overall_conv_ratio' => 0.2222222222222222 }
                          ] }
      }
    }
  end

  def real_booking_flow_funnel_response
    { 'meta' => { 'property_values' => %w(1 3) }, 'data' =>
     { '2013-08-20' =>
      { '1' => [
        { 'count' => 802, 'step_conv_ratio' => 1, 'goal' => 'Conducted a Search', 'overall_conv_ratio' => 1, 'avg_time' => nil, 'event' => 'Conducted a Search' },
        { 'count' => 133, 'step_conv_ratio' => 0.1658354114713217, 'goal' => 'Viewed a Location', 'overall_conv_ratio' => 0.1658354114713217, 'avg_time' => 48, 'event' => 'Viewed a Location' },
        { 'count' => 3, 'step_conv_ratio' => 0.022556390977443608, 'goal' => 'Opened the Booking Modal', 'overall_conv_ratio' => 0.003740648379052369, 'avg_time' => 224, 'event' => 'Opened the Booking Modal' },
        { 'count' => 1, 'step_conv_ratio' => 0.3333333333333333, 'goal' => 'Requested a Booking', 'overall_conv_ratio' => 0.0012468827930174563, 'avg_time' => 16, 'event' => 'Requested a Booking' }
      ],
        '3' => [
          { 'count' => 1, 'step_conv_ratio' => 1, 'goal' => 'Conducted a Search', 'overall_conv_ratio' => 1, 'avg_time' => nil, 'event' => 'Conducted a Search' },
          { 'count' => 0, 'step_conv_ratio' => 0.0, 'goal' => 'Viewed a Location', 'overall_conv_ratio' => 0.0, 'avg_time' => nil, 'event' => 'Viewed a Location' },
          { 'count' => 0, 'step_conv_ratio' => 0, 'goal' => 'Opened the Booking Modal', 'overall_conv_ratio' => 0.0, 'avg_time' => nil, 'event' => 'Opened the Booking Modal' },
          { 'count' => 0, 'step_conv_ratio' => 0, 'goal' => 'Requested a Booking', 'overall_conv_ratio' => 0.0, 'avg_time' => nil, 'event' => 'Requested a Booking' }
        ],
        '$overall' => [
          { 'count' => 803, 'step_conv_ratio' => 1, 'avg_time' => nil, 'event' => 'Conducted a Search', 'overall_conv_ratio' => 1 },
          { 'count' => 133, 'step_conv_ratio' => 0.1656288916562889, 'avg_time' => 48, 'event' => 'Viewed a Location', 'overall_conv_ratio' => 0.1656288916562889 },
          { 'count' => 3, 'step_conv_ratio' => 0.022556390977443608, 'avg_time' => 224, 'event' => 'Opened the Booking Modal', 'overall_conv_ratio' => 0.0037359900373599006 },
          { 'count' => 1, 'step_conv_ratio' => 0.3333333333333333, 'avg_time' => 16, 'event' => 'Requested a Booking', 'overall_conv_ratio' => 0.0012453300124533001 }
        ] },
       '2013-08-27' =>
      { '1' => [
        { 'count' => 53, 'step_conv_ratio' => 1, 'goal' => 'Conducted a Search', 'overall_conv_ratio' => 1, 'avg_time' => nil, 'event' => 'Conducted a Search' },
        { 'count' => 15, 'step_conv_ratio' => 0.2830188679245283, 'goal' => 'Viewed a Location', 'overall_conv_ratio' => 0.2830188679245283, 'avg_time' => 83, 'event' => 'Viewed a Location' },
        { 'count' => 2, 'step_conv_ratio' => 0.13333333333333333, 'goal' => 'Opened the Booking Modal', 'overall_conv_ratio' => 0.03773584905660377, 'avg_time' => 23, 'event' => 'Opened the Booking Modal' },
        { 'count' => 0, 'step_conv_ratio' => 0.0, 'goal' => 'Requested a Booking', 'overall_conv_ratio' => 0.0, 'avg_time' => nil, 'event' => 'Requested a Booking' }
      ],
        '$overall' => [
          { 'count' => 53, 'step_conv_ratio' => 1, 'avg_time' => nil, 'event' => 'Conducted a Search', 'overall_conv_ratio' => 1 },
          { 'count' => 15, 'step_conv_ratio' => 0.2830188679245283, 'avg_time' => 83, 'event' => 'Viewed a Location', 'overall_conv_ratio' => 0.2830188679245283 },
          { 'count' => 2, 'step_conv_ratio' => 0.13333333333333333, 'avg_time' => 23, 'event' => 'Opened the Booking Modal', 'overall_conv_ratio' => 0.03773584905660377 },
          { 'count' => 0, 'step_conv_ratio' => 0.0, 'avg_time' => 0, 'event' => 'Requested a Booking', 'overall_conv_ratio' => 0.0 }
        ] } } }
  end
end
