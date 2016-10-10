require 'test_helper'

class InstanceAdmin::Settings::LocationTypesControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  end

  context 'create and index' do
    should 'create a new location type' do
      assert_difference 'LocationType.count', 1 do
        post :create, 'location_type' => { 'name' => 'new location type' }
      end

      assert_equal 'New location type added.', flash[:success]
      assert_redirected_to instance_admin_settings_locations_path
    end

    should 'not create a new location type' do
      assert_no_difference 'LocationType.count' do
        post :create, 'location_type' => { 'name' => '' }
      end

      assert_equal "Location type can't be blank", flash[:error]
      assert_redirected_to instance_admin_settings_locations_path
    end

    should 'redirect to the admin settings path on index action' do
      get :index
      assert_redirected_to instance_admin_settings_configuration_path
    end
  end

  context 'destroy' do
    setup do
      @location_type_1 = FactoryGirl.create(:location_type, name: 'Location type 1')
      @location_type_2 = FactoryGirl.create(:location_type, name: 'Location type 2')
      @location_type_3 = FactoryGirl.create(:location_type, name: 'Location type 3')
      @location_2 = FactoryGirl.create(:location, location_type: @location_type_2)
      @location_3 = FactoryGirl.create(:location, location_type: @location_type_3)
    end

    should 'render the destroy modal' do
      get :destroy_modal, id: @location_type_1.id
      assert_equal @location_type_1, assigns(:location_type)
      assert_template :destroy_modal
    end

    should 'assign correct type and replacement types options and render the destroy modal' do
      get :destroy_modal, id: @location_type_2.id
      assert_equal @location_type_2, assigns(:location_type)
      assert_equal [@location_type_1, @location_type_3], assigns(:replacement_types).sort
      assert_template :destroy_and_replace_modal
    end

    should 'destroy location type' do
      assert_difference 'LocationType.count', -1 do
        post :destroy, id: @location_type_1.id
      end

      assert_equal 'Location type deleted.', flash[:success]
      assert_redirected_to instance_admin_settings_locations_path
    end

    should 'replace location type and destroy' do
      assert_difference 'LocationType.count', -1 do
        post :destroy, id: @location_type_2.id, replacement_type_id: @location_type_3.id
      end

      assert_equal @location_2.reload.location_type, @location_type_3
      assert_equal 'Location type deleted.', flash[:success]
      assert_redirected_to instance_admin_settings_locations_path
    end
  end

  context 'update' do
    setup do
      @location_type = FactoryGirl.create(:location_type, name: 'Location type')
    end

    should 'fail if request is not xhr' do
      assert_raise ActionController::MethodNotAllowed do
        patch :update, id: @location_type.id, location_type: { name: 'new name' }
      end
    end

    should 'successfully update location type' do
      new_name = 'Updated'
      xhr :patch, :update, id: @location_type.id, location_type: { name: new_name }
      assert_equal new_name, @location_type.reload.name
    end
  end
end
