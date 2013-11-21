require 'test_helper'
require 'helpers/search_params_test_helper'

class EventTrackerTest < ActiveSupport::TestCase
  include SearchParamsTestHelper

  setup do
    @user = FactoryGirl.create(:user)
    @mixpanel = stub() # Represents our internal MixpanelApi instance
    @google_analytics = stub()
    @tracker = Analytics::EventTracker.new(@mixpanel, @google_analytics)
  end

  context 'store taggable tracked events' do

    setup do 
      @category = "User events"
      expect_set_person_properties user_properties
      expect_event 'Logged In', user_properties
      @tracker.logged_in(@user)
    end

    should 'be able to store single method' do
      assert_equal ['Logged in'], @tracker.triggered_client_taggable_methods
    end

    should 'be able to store multiple methods' do
      expect_set_person_properties user_properties
      expect_event 'Signed Up', user_properties
      @tracker.signed_up(@user)
      assert_equal ['Logged in', 'Signed up'], @tracker.triggered_client_taggable_methods
    end
    
  end

  context 'Listings' do
    setup do
      @listing = FactoryGirl.create(:listing)
      @category = "Listing events"
    end

    should 'track listing creation' do
      expect_event 'Created a Listing', listing_properties
      @tracker.created_a_listing(@listing)
    end
  end

  context 'Locations' do
    setup do
      @location = FactoryGirl.create(:location)
      @search = build_search_params(options_with_location)
      @category = "Location events"
    end

    should 'track location creation' do
      expect_event 'Created a Location', location_properties
      @tracker.created_a_location(@location)
    end

    should 'track location view' do
      expect_event 'Viewed a Location', location_properties
      @tracker.viewed_a_location(@location)
    end

    should 'track search' do
      expect_event 'Conducted a Search', search_properties
      @tracker.conducted_a_search(@search)
    end

    should 'track shared location via social media' do
      expect_event 'Shared location via social media', location_properties.merge!({ provider: 'facebook', source: 'email' })
      @tracker.shared_location_via_social_media(@location, { provider: 'facebook', source: 'email' })
    end
  end

  context 'Reservations' do
    setup do
      @reservation = FactoryGirl.create(:reservation)
      @category = "Reservation events"
    end

    should 'track booking modal open' do
      expect_event 'Opened the Booking Modal', reservation_properties
      @tracker.opened_booking_modal(@reservation)
    end

    should 'track a booking request' do
      expect_event 'Requested a Booking', reservation_properties
      @tracker.requested_a_booking(@reservation)
    end

    should 'track a booking confirmation' do
      expect_event 'Confirmed a Booking', reservation_properties
      # commented out because I don't think these are semantically correct?
      #expect_charge @reservation.owner.id, 50.0
      @tracker.confirmed_a_booking(@reservation)
    end

    should 'track a booking rejection' do
      expect_event 'Rejected a Booking', reservation_properties
      @tracker.rejected_a_booking(@reservation)
    end

    should 'track a booking cancellation with custom options' do
      expect_event 'Cancelled a Booking', reservation_properties.merge!({ actor: 'host'})
      # commented out because I don't think these are semantically correct?
      #expect_charge @reservation.owner.id, -50.0
      @tracker.cancelled_a_booking(@reservation, { actor: 'host'})
    end

    should 'track a booking expiry' do
      expect_event 'Booking Expired', reservation_properties
      @tracker.booking_expired(@reservation)
    end
  end

  context 'Space Wizard' do

    setup do
      @category = "Space wizard events"
    end

    should 'track click list your bookable' do
      expect_event 'Clicked List your Bookable', {}
      @tracker.clicked_list_your_bookable
    end

    should 'track view list your bookable' do
      expect_event 'Viewed List Your First Bookable', {}
      @tracker.viewed_list_your_bookable
    end
  end

  context 'Users' do

    setup do
      @category = "User events"
    end

    should 'track user sign up' do
      expect_set_person_properties user_properties
      expect_event 'Signed Up', user_properties
      @tracker.signed_up(@user)
    end

    should 'track user log in' do
      expect_set_person_properties user_properties
      expect_event 'Logged In', user_properties
      @tracker.logged_in(@user)
    end

    should 'set new proprties after updating profile' do
      expect_set_person_properties user_properties
      @mixpanel.expects(:track).never
      @tracker.updated_profile_information(@user)
    end

    should 'track user social provider connection' do
      expect_set_person_properties user_properties
      expect_event 'Connected Social Provider', user_properties
      @tracker.connected_social_provider(@user)
    end

    should 'track user social provider disconnection' do
      expect_set_person_properties user_properties
      expect_event 'Disconnected Social Provider', user_properties
      @tracker.disconnected_social_provider(@user)
    end

    should 'track photo not processed before submit' do
      expect_set_person_properties user_properties
      expect_event 'Photo not processed before form submit', user_properties
      @tracker.photo_not_processed_before_submit(@user)
    end

    should 'track user closed browser photo not processed before submit' do
      expect_set_person_properties user_properties
      expect_event 'User closed browser window when photo not processed before form submit', user_properties
      @tracker.user_closed_browser_photo_not_processed_before_submit(@user)
    end
  end

  context 'Mailer' do

    setup do
      @category = "Mailer events"
    end

    should 'track find a desk clicked' do
      expect_event 'Clicked link within email', user_properties.merge!({ url: '/manage/locations', mailer: 'recurring_mailer/analytics' })
      @tracker.link_within_email_clicked(@user, { url: '/manage/locations', mailer: 'recurring_mailer/analytics' })
    end

  end

  should 'trigger mixpanel method to get pixel based tracking url' do
    event_name = 'Some event'
    properties = { some: 'event' }
    @mixpanel.expects(:pixel_track_url).with(event_name, properties)
    @tracker.pixel_track_url(event_name, properties)
  end

  private

  def expect_event(event_name, properties = nil)
    @mixpanel.expects(:track).with(event_name, properties)
    @google_analytics.expects(:track).with(@category, event_name)
  end


  def expect_charge(user_id, total_amount_dollars)
    @mixpanel.expects(:track_charge).with(user_id, total_amount_dollars)
  end

  def expect_append_alias(user_id)
    @mixpanel.expects(:append_alias).with(user_id)
  end

  def expect_set_person_properties(user)
    @mixpanel.expects(:set_person_properties).with(user)
  end

  def build_search_params(options)
    Listing::Search::Params::Web.new(options)
  end

  def reservation_properties
    {
      booking_desks: @reservation.quantity,
      booking_days: @reservation.total_days,
      booking_total: @reservation.total_amount_dollars,
      location_address: @reservation.location.address,
      location_currency: @reservation.location.currency,
      location_suburb: @reservation.location.suburb,
      location_city: @reservation.location.city,
      location_state: @reservation.location.state,
      location_country: @reservation.location.country,
      location_postcode: @reservation.location.postcode
    }
  end

  def listing_properties
    {
      listing_name: @listing.name,
      listing_quantity: @listing.quantity,
      listing_confirm: @listing.confirm_reservations,
      listing_daily_price: @listing.daily_price.try(:dollars),
      listing_weekly_price: @listing.weekly_price.try(:dollars),
      listing_monthly_price: @listing.monthly_price.try(:dollars),
      listing_url: "http://example.com/listings/#{@listing.to_param}"
    }
  end

  def location_properties
    {
      location_address: @location.address,
      location_currency: @location.currency,
      location_suburb: @location.suburb,
      location_city: @location.city,
      location_state: @location.state,
      location_country: @location.country,
      location_postcode: @location.postcode,
      location_url: "http://example.com/locations/#{@location.id}"
    }
  end

  def user_properties
    {
      first_name: @user.first_name,
      last_name: @user.last_name,
      industries: @user.industries.map(&:name),
      email: @user.email,
      phone: @user.phone,
      job_title: @user.job_title,
      created: @user.created_at,
      location_number: @user.locations.count,
      listing_number: @user.listings.count,
      bookings_total: @user.reservations.count,
      bookings_confirmed: @user.confirmed_reservations.count,
      bookings_rejected: @user.rejected_reservations.count,
      bookings_expired: @user.expired_reservations.count,
      bookings_cancelled: @user.cancelled_reservations.count,
      google_analytics_id: @user.google_analytics_id,
      browser: @user.browser,
      browser_version: @user.browser_version,
      platform: @user.platform,
      positive_host_ratings_count: @user.host_ratings.positive.count,
      negative_host_ratings_count: @user.host_ratings.negative.count,
      positive_guest_ratings_count: @user.guest_ratings.positive.count,
      negative_guest_ratings_count: @user.guest_ratings.negative.count
    }
  end

  def search_properties
    {
      search_street: @search.street,
      search_suburb: @search.suburb,
      search_city: @search.city,
      search_state: @search.state,
      search_country: @search.country,
      search_postcode: @search.postcode
    }
  end
end

