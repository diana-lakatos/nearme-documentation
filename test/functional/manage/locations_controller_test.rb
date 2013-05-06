require 'test_helper'

class Manage::LocationsControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @company = FactoryGirl.create(:company, :creator => @user)
    @location_type = FactoryGirl.create(:location_type)
  end

  should "get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:locations)
  end

  context "#create" do

    should "create location" do
      assert_difference('@user.locations.count') do
        post :create, { :location => FactoryGirl.attributes_for(:location_in_auckland).reverse_merge!({:location_type_id => @location_type.id})}
      end
      assert_redirected_to manage_locations_path
    end
  end

  context "with location" do

    setup do
      @location = FactoryGirl.create(:location_in_auckland, :company => @company)
    end

    should "update location" do
      put :update, :id => @location.id, :location => { :description => 'new description' }
      @location.reload
      assert_equal 'new description', @location.description
      assert_redirected_to manage_locations_path
    end

    should "destroy location" do
      assert_difference('@user.locations.count', -1) do
        delete :destroy, :id => @location.id
      end

      assert_redirected_to manage_locations_path
    end

    context "someone else tries to manage our location" do

      setup do
        @other_user = FactoryGirl.create(:user)
        FactoryGirl.create(:company, :creator => @other_user)
        sign_in @other_user
      end

      context "#create" do

        should "create location" do
          assert_no_difference('@user.locations.count') do
            post :create, { :location => FactoryGirl.attributes_for(:location_in_auckland).reverse_merge!({:location_type_id => @location_type.id})}
          end
        end
      end

      should "update location" do
        put :update, :id => @location.id, :location => { :description => 'new description' }
        @location.reload
        assert_not_equal 'new description', @location.description
      end

      should "destroy location" do
        assert_no_difference('@user.locations.count', -1) do
          delete :destroy, :id => @location.id
        end
      end
    end
  end


end
