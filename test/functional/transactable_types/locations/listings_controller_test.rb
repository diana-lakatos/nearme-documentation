require 'test_helper'

class TransactableTypes::Locations::ListingsControllerTest < ActionController::TestCase

  setup do
    @listing = FactoryGirl.create(:transactable)
    @transactable_type = @listing.transactable_type
    @location = @listing.location
  end

  should "redirect to locations#show and remember which listing has been chosen if show page disabled" do
    get :show, transactable_type_id: @transactable_type.id, location_id: @location.id, id: @listing
    assert_response :redirect
    assert_redirected_to transactable_type_location_path(@listing.transactable_type, @location, @listing)
  end

  context 'show page enabled' do

    setup do
      @listing.transactable_type.update_attribute(:show_page_enabled, true)
    end

    should 'render show action' do
      get :show, transactable_type_id: @transactable_type.id, location_id: @location.id, id: @listing.id
      assert_response :success
    end

    should 'track impression' do
      assert_difference 'Impression.count' do
        get :show, transactable_type_id: @transactable_type.id, location_id: @location.id, id: @listing.id
      end
    end

    should 'track viewed_a_location event' do
      Rails.application.config.event_tracker.any_instance.expects(:viewed_a_listing).with do |listing|
        listing == assigns(:listing)
      end
      get :show, transactable_type_id: @transactable_type.id, location_id: @location.id, id: @listing.id
    end

    context 'listing is disabled' do
      setup do
        @listing.update_attributes(enabled: false)
      end

      should 'show warning if user cannot manage listing and there is at least one active listing' do
        get :show, transactable_type_id: @transactable_type.id, location_id: @location.id, id: @listing.id
        assert_response :redirect
        assert_redirected_to location_path(@location)
        assert flash[:warning].include?('This listing has been temporarily disabled by the owner'), "Expected #{flash[:warning]} to include 'This listing is inactive'"
      end

      should 'show warning if random user is logged in' do
        sign_in FactoryGirl.create(:user)
        get :show, transactable_type_id: @transactable_type.id, location_id: @location.id, id: @listing.id
        assert_response :redirect
        assert_redirected_to location_path(@location)
        assert flash[:warning].include?('This listing has been temporarily disabled by the owner'), "Expected #{flash[:warning]} to include 'This listing is inactive'"
      end

      should 'show warning but do not redirect if user can manage listing' do
        sign_in @location.creator
        get :show, transactable_type_id: @transactable_type.id, location_id: @location.id, id: @listing.id
        assert_response :success
        assert_not_nil flash[:warning]
      end

    end
  end

end

