require 'test_helper'

class InstanceAdmin::Settings::ListingTypesControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  end

  context 'create and index' do
    should 'create a new listing type' do
      assert_difference 'ListingType.count', 1 do
        post :create, "listing_type"=>{"name"=>"new listing type"}
      end

      assert_equal 'New listing type added.', flash[:success]
      assert_redirected_to instance_admin_settings_path
    end

    should 'not create a new listing type' do
      assert_no_difference 'ListingType.count' do
        post :create, "listing_type"=>{"name"=>""}
      end

      assert_equal 'Could not add new listing type.', flash[:error]
      assert_redirected_to instance_admin_settings_path
    end

    should 'redirect to the admin settings path on index action' do
      get :index
      assert_redirected_to instance_admin_settings_path
    end
  end

  context 'destroy' do
    setup do
      @listing_type_1 = FactoryGirl.create(:listing_type, name: "Listing type 1")
      @listing_type_2 = FactoryGirl.create(:listing_type, name: "Listing type 2")
      @listing_type_3 = FactoryGirl.create(:listing_type, name: "Listing type 3")
      @listing_2 = FactoryGirl.create(:listing, listing_type: @listing_type_2)
      @listing_3 = FactoryGirl.create(:listing, listing_type: @listing_type_3)
    end

    should 'render the destroy modal' do
      get :destroy_modal, id: @listing_type_1.id
      assert_equal @listing_type_1, assigns(:listing_type)
      assert_template :destroy_modal
    end

    should 'assign correct type and replacement types options and render the destroy modal' do
      get :destroy_modal, id: @listing_type_2.id
      assert_equal @listing_type_2, assigns(:listing_type)
      assert_equal [@listing_type_1, @listing_type_3], assigns(:replacement_types).sort
      assert_template :destroy_and_replace_modal
    end

    should 'destroy listing type' do
      assert_difference 'ListingType.count', -1 do
        post :destroy, id: @listing_type_1.id
      end

      assert_equal 'Listing type deleted.', flash[:success]
      assert_redirected_to instance_admin_settings_path
    end

    should 'replace listing type and destroy' do
      assert_difference 'ListingType.count', -1 do
        post :destroy, id: @listing_type_2.id, replacement_type_id: @listing_type_3.id
      end

      assert_equal @listing_2.reload.listing_type, @listing_type_3
      assert_equal 'Listing type deleted.', flash[:success]
      assert_redirected_to instance_admin_settings_path
    end
  end
end
