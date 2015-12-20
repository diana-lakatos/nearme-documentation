require 'test_helper'

class LocationsControllerTest < ActionController::TestCase

  setup do
    @location = FactoryGirl.create(:location_in_auckland)
    @listing = FactoryGirl.create(:transactable, :location => @location)
    @second_listing = FactoryGirl.create(:transactable, :location => @location)
  end

  context '#show' do

    should 'track impression' do
      assert_difference 'Impression.count' do
        get :show, id: @location.id
      end
    end

    context 'without listing' do

      should "work" do
        get :show, id: @location.id
        assert_response :success
      end

      should 'track viewed_a_location event' do
        Rails.application.config.event_tracker.any_instance.expects(:viewed_a_location).with do |location|
          location == assigns(:location)
        end
        get :show, id: @location.id
      end

    end

    context 'with listing' do

      should 'track viewed_a_location event' do
        Rails.application.config.event_tracker.any_instance.expects(:viewed_a_location).with do |location|
          location == assigns(:location)
        end
        get :show, id: @location.id, listing_id: @listing
      end

      should 'render show action if show page disabled' do
        get :show, id: @location.id, listing_id: @listing
        assert_response :success
      end

      should 'display a content holder' do
        holder = FactoryGirl.create :content_holder, inject_pages: ['service/product_page'], content: "{{ @listing.street }} and whatever"
        get :show, id: @location.id, listing_id: @listing
        assert response.body.include?("#{@listing.location.street} and whatever")
      end

      should 'display two content holders' do
        holder = FactoryGirl.create :content_holder, inject_pages: ['service/product_page'], content: "{{ @listing.street }} and whatever"
        holder = FactoryGirl.create :content_holder, inject_pages: ['service/product_page'], content: "This is an id of listing: {{ @listing.id }}"
        get :show, id: @location.id, listing_id: @listing
        assert response.body.include?("#{@listing.location.street} and whatever")
        assert response.body.include?("This is an id of listing: #{ @listing.id }")
      end

      should 'redirect to individual listing page if enabled' do
        @listing.transactable_type.update_attribute(:show_page_enabled, true)
        get :show, id: @location.id, listing_id: @listing
        assert_response :redirect
        assert_redirected_to transactable_type_location_listing_path(@listing.transactable_type, @location, @listing)
      end

      should 'show warning if listing is inactive but there is at least one active listing' do
        @listing.update_attributes(draft: Time.now)
        get :show, id: @location.id, listing_id: @listing
        assert_response :redirect
        assert_redirected_to location_path(@location)
        assert flash[:warning].include?('This listing is inactive'), "Expected #{flash[:warning]} to include 'This listing is inactive'"
      end

      context 'listing is disabled' do
        setup do
          @listing.update_attributes(enabled: false)
        end

        should 'show warning if user cannot manage listing and there is at least one active listing' do
          get :show, id: @location.id, listing_id: @listing
          assert_response :redirect
          assert_redirected_to location_path(@location)
          assert flash[:warning].include?('This listing has been temporarily disabled by the owner'), "Expected #{flash[:warning]} to include 'This listing is inactive'"
        end

        should 'show warning if random user is logged in' do
          sign_in FactoryGirl.create(:user)
          get :show, id: @location.id, listing_id: @listing
          assert_response :redirect
          assert_redirected_to location_path(@location)
          assert flash[:warning].include?('This listing has been temporarily disabled by the owner'), "Expected #{flash[:warning]} to include 'This listing is inactive'"
        end

        should 'show warning but not redirect if user can manage listing' do
          sign_in @location.creator
          get :show, id: @location.id, listing_id: @listing
          assert_response :success
          assert_not_nil flash[:warning]
        end
      end

      should 'redirect to search if listing is inactive and there are no other listings' do
        @second_listing.destroy
        @listing.update_attributes(draft: Time.now, enabled: false)
        get :show, id: @location.id, listing_id: @listing
        assert_redirected_to search_path(loc: @listing.address)
      end
    end

  end
end
