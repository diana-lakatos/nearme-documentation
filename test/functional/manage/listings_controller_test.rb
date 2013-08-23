require 'test_helper'

class Manage::ListingsControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @company = FactoryGirl.create(:company, :creator => @user)
    @location = FactoryGirl.create(:location, :company => @company)
    @location2 = FactoryGirl.create(:location, :company => @company)
    @listing_type = FactoryGirl.create(:location_type)
  end

  context "#create" do

    should "create listing and log" do
      stub_mixpanel
      @tracker.expects(:created_a_listing).with do |listing, custom_options|
        listing == assigns(:listing) && custom_options == { via: 'dashboard' }
      end
      @tracker.expects(:updated_profile_information).with do |user|
        user == @user
      end
      assert_difference('@location2.listings.count') do
        post :create, {
          :listing => FactoryGirl.attributes_for(:listing).reverse_merge!({:photos_attributes => [FactoryGirl.attributes_for(:photo)], :listing_type_id => @listing_type.id, :daily_price => 10 }),
          :location_id => @location2.id
        }
      end
      assert_redirected_to manage_locations_path
    end
  end

  context "with listing" do

    setup do
      @listing = FactoryGirl.create(:listing, :location => @location, :photos_count => 1)
    end

    should "update listing" do
      put :update, :id => @listing.id, :listing => { :name => 'new name' }
      @listing.reload
      assert_equal 'new name', @listing.name
      assert_redirected_to manage_locations_path
    end

    should "destroy listing" do
      stub_mixpanel
      @tracker.expects(:updated_profile_information).with do |user|
        user == @user
      end
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

      should "not create listing" do
        assert_raise ActiveRecord::RecordNotFound do
          post :create, { :listing => FactoryGirl.attributes_for(:listing).reverse_merge!({:listing_type_id => @listing_type.id}), :location_id => @location.id}
        end
      end

      should "not update listing" do
        assert_raise ActiveRecord::RecordNotFound do
          put :update, :id => @listing.id, :listing => { :name => 'new name' }
        end
      end

      should "not destroy listing" do
        assert_raise ActiveRecord::RecordNotFound do
          delete :destroy, :id => @listing.id
        end
      end
    end
  end


end
