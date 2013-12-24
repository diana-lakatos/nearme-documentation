require 'test_helper'

class InstanceAdmin::Settings::LocationTypesControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdmin::Authorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdmin::Authorizer.any_instance.stubs(:authorized?).returns(true)
  end

  context 'create and index' do
    should 'create a new location type' do
      assert_difference 'LocationType.count', 1 do
        post :create, "location_type"=>{"name"=>"new location type"}
      end

      assert_equal 'New location type added.', flash[:success]
      assert_redirected_to instance_admin_settings_path
    end

    should 'not create a new location type' do
      assert_no_difference 'LocationType.count' do
        post :create, "location_type"=>{"name"=>""}
      end

      assert_equal 'Could not add new location type.', flash[:error]
      assert_redirected_to instance_admin_settings_path
    end

    should 'redirect to the admin settings path on index action' do
      get :index
      assert_redirected_to instance_admin_settings_path
    end
  end

  context 'destroy' do
    setup do
      @location_type_1 = FactoryGirl.create(:location_type, name: "Location type 1")
      @location_type_2 = FactoryGirl.create(:location_type, name: "Location type 2")
      @location_type_3 = FactoryGirl.create(:location_type, name: "Location type 3")
      @location_1 = FactoryGirl.create(:location, location_type: @location_type_1)
      @location_2 = FactoryGirl.create(:location, location_type: @location_type_2)
      @location_3 = FactoryGirl.create(:location, location_type: @location_type_3)
    end

    should 'assign correct type and replacement types options and render the destroy modal' do
      get :destroy_modal, id: @location_type_2.id
      assert_equal @location_type_2, assigns(:location_type)
      assert_equal [@location_type_1, @location_type_3], assigns(:replacement_types).sort
      assert_template :destroy_modal
    end

    should 'replace location type and destroy' do
      assert_difference 'LocationType.count', -1 do
        post :destroy, id: @location_type_2.id, replacement_type_id: @location_type_3.id
      end

      assert_equal @location_2.reload.location_type, @location_type_3
      assert_equal 'Location type deleted.', flash[:success]
      assert_redirected_to instance_admin_settings_path
    end

    should 'not replace incorrect listing type and destroy' do
      assert_no_difference 'LocationType.count' do
        post :destroy, id: @location_type_2.id, replacement_type_id: nil
      end

      assert_equal 'Location type could not be deleted.', flash[:error]
      assert_redirected_to instance_admin_settings_path
    end
  end
end
