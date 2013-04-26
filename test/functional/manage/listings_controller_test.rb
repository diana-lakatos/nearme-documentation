require 'test_helper'

class Manage::ListingsControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @company = FactoryGirl.create(:company, :creator => @user)
    @location = FactoryGirl.create(:location, :company => @company)
    @location2 = FactoryGirl.create(:location, :company => @company)
    @listing_type = FactoryGirl.create(:location_type)
  end

  context "#create" do

    should "create listing" do
      assert_difference('@location2.listings.count') do
        post :create, { :listing => FactoryGirl.attributes_for(:listing_in_auckland).reverse_merge!({:listing_type_id => @listing_type.id}), :location_id => @location2.id}
      end
      assert_redirected_to manage_locations_path
    end
  end

  context "with listing" do

    setup do
      @listing = FactoryGirl.create(:listing_in_auckland, :location => @location)
    end

    should "update listing" do
      put :update, :id => @listing.id, :listing => { :name => 'new name' }
      @listing.reload
      assert_equal 'new name', @listing.name
      assert_redirected_to manage_locations_path
    end

    should "destroy listing" do
      assert_difference('@user.listings.count', -1) do
        delete :destroy, :id => @listing.id
      end

      assert_redirected_to manage_locations_path
    end

    context "someone else tries to manage our listing" do

      setup do
        @other_user = FactoryGirl.create(:user)
        @other_company = FactoryGirl.create(:company, :creator => @other_user)
        @other_locaiton = FactoryGirl.create(:location, :company => @company)
        sign_in @other_user
      end

      context "#create" do

        should "create listing" do
          assert_no_difference('@user.listings.count') do
            # @location belongs to @user, not signed in @other_user - @user should not get new listing
            post :create, { :listing => FactoryGirl.attributes_for(:listing).reverse_merge!({:listing_type_id => @listing_type.id}), :location_id => @location.id}
          end
        end
      end

      should "update listing" do
        put :update, :id => @listing.id, :listing => { :name => 'new name' }
        @listing.reload
        assert_not_equal 'new name', @listing.name
      end

      should "destroy listing" do
        assert_no_difference('@user.listings.count', -1) do
          delete :destroy, :id => @listing.id
        end
      end
    end
  end


end
