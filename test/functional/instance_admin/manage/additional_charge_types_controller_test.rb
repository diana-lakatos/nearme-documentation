require 'test_helper'

class InstanceAdmin::Manage::AdditionalChargeTypesControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user, name: 'John X')
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'index action' do
    setup do
      @act = FactoryGirl.create(:additional_charge_type)
    end

    should 'get index' do
      get :index
      assert_response :success
      assert assigns[:additional_charge_types], [@act]
      assert_template :index
    end
  end

  context 'when creating new act' do
    should 'get new' do
      get :new
      assert_response :success
      assert_not_nil assigns[:additional_charge_type]
      assert_select 'form#new_additional_charge_type'
    end

    should 'create a new record' do
      params = FactoryGirl.attributes_for(:additional_charge_type)
      assert_difference 'AdditionalChargeType.count', 1 do
        post :create, additional_charge_type: params
      end
      assert_redirected_to instance_admin_manage_additional_charge_types_path
    end

    should 'not render new when invalid params' do
      params = FactoryGirl.attributes_for(:additional_charge_type).merge(status: 'invalid')
      assert_difference 'AdditionalChargeType.count', 0 do
        post :create, additional_charge_type: params
      end
      assert_template :new
    end
  end

  context 'should update act' do
    setup do
      @act = FactoryGirl.create(:additional_charge_type)
    end
    should 'get edit' do
      get :edit, id: @act.id
      assert_template :edit
      assert assigns[:additional_charge_type], @act
    end

    should 'update with valid params' do
      params = { status: 'optional' }
      put :update, id: @act.id, additional_charge_type: params
      assert_redirected_to instance_admin_manage_additional_charge_types_path
      assert @act.status, params[:status]
    end

    should 'render edit when invalid params' do
      params = { status: 'invalid' }
      put :update, id: @act.id, additional_charge_type: params
      assert_template :edit
      assert_not_equal @act.status, params[:status]
    end
  end

  should 'delete record' do
    act = FactoryGirl.create(:additional_charge_type)
    assert_difference 'AdditionalChargeType.count', -1 do
      delete :destroy, id: act.id
    end
    assert_redirected_to instance_admin_manage_additional_charge_types_path
  end
end
