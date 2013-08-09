require 'test_helper'
require 'helpers/search_params_test_helper'

class EventTrackerTest < ActiveSupport::TestCase
  include SearchParamsTestHelper

  setup do
    @user = FactoryGirl.create(:user)
    @mixpanel = stub() # Represents our internal MixpanelApi instance
    @tracker = Analytics::EventTracker.new(@mixpanel)
  end

  context 'Listings' do
    setup do
      @listing = FactoryGirl.create(:listing)
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
  end

  context 'Reservations' do
    setup do
      @reservation = FactoryGirl.create(:reservation)
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
    should 'track sign up step of flow' do
      expect_event 'Viewed List Your Space, Sign Up', {}
      @tracker.viewed_list_your_space_sign_up
    end

    should 'track list step of flow' do
      expect_event 'Viewed List Your Space, List', {}
      @tracker.viewed_list_your_space_list
    end
  end

  context 'Users' do
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
  end

  private

  def expect_event(event_name, properties = nil)
    @mixpanel.expects(:track).with(event_name, properties)
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
      listing_monthly_price: @listing.monthly_price.try(:dollars)
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
      location_postcode: @location.postcode
    }
  end

  def user_properties
    {
      first_name: @user.first_name,
      last_name: @user.last_name,
      email: @user.email,
      phone: @user.phone,
      job_title: @user.job_title,
      created: @user.created_at
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

