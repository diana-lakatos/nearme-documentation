require 'test_helper'

class InstanceAdmin::Manage::TransactableTypes::CustomValidatorsControllerTest < ActionController::TestCase

  setup do
    @instance = FactoryGirl.create(:instance)
    PlatformContext.current = PlatformContext.new(@instance)
    @transactable_type = FactoryGirl.create(:transactable_type_csv_template)
    FactoryGirl.create(:location_type, name: 'My Type') unless LocationType.where(name: 'My Type').count > 0
    @user = FactoryGirl.create(:user)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  should '#index' do
    @custom_validator = FactoryGirl.create(:custom_validator, validatable: @transactable_type, required: 1)
    get :index, transactable_type_id: @transactable_type.id
    assert_response :success
    assert_equal [@custom_validator], assigns(:validators)
  end

  should '#new' do
    get :new, transactable_type_id: @transactable_type.id
    assert_response :success
  end

  context 'create' do
    should 'create new custom validator' do
      assert_difference 'CustomValidator.count' do
        post :create, transactable_type_id: @transactable_type.id, custom_validator: { field_name: 'description', required: 1 }
      end
      custom_validator = assigns(:custom_validator)
      assert_equal 'description', custom_validator.field_name
      assert_equal Hash.new, custom_validator.validation_rules['presence']
      assert_equal @transactable_type.id, custom_validator.validatable_id
      assert_redirected_to instance_admin_manage_transactable_type_custom_validators_path(@transactable_type)
    end

    should 'render form if validation errors' do
      assert_no_difference 'CustomValidator.count' do
        post :create, transactable_type_id: @transactable_type.id, custom_validator: { required: 1}
      end
      assert_response :success
    end
  end

  should 'edit' do
    @custom_validator = FactoryGirl.create(:custom_validator)
    get :edit, transactable_type_id: @transactable_type.id, id: @custom_validator.id
    assert_response :success
  end

  context 'update' do

    setup do
      @custom_validator = FactoryGirl.create(:custom_validator)
    end

    should 'update form compponents' do
      assert_no_difference 'CustomValidator.count' do
        put :update, transactable_type_id: @transactable_type.id, id: @custom_validator.id, custom_validator: { field_name: 'description', valid_values: 'true,false'}
      end
      custom_validator = assigns(:validator)
      custom_validator.reload
      assert_equal 'description', custom_validator.field_name
      assert_equal custom_validator.valid_values, ['true', 'false']
      assert_redirected_to instance_admin_manage_transactable_type_custom_validators_path(@transactable_type)
    end

  end

  should 'destroy' do
    @custom_validator = FactoryGirl.create(:custom_validator)
    assert_difference 'CustomValidator.count', -1 do
      delete :destroy, transactable_type_id: @transactable_type.id, id: @custom_validator.id
    end
    assert_redirected_to instance_admin_manage_transactable_type_custom_validators_path(@transactable_type)
  end

end

