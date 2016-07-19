require 'test_helper'

class InstanceAdmin::Manage::TransactableTypes::FormComponentsControllerTest < ActionController::TestCase

  setup do
    @instance = FactoryGirl.create(:instance)
    PlatformContext.current = PlatformContext.new(@instance)
    @transactable_type = FactoryGirl.build(:transactable_type_csv_template)
    @transactable_type.save!
    FactoryGirl.create(:location_type, name: 'My Type') unless LocationType.where(name: 'My Type').count > 0
    @user = FactoryGirl.create(:user)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  should '#index' do
    @form_component = FactoryGirl.create(:form_component, form_componentable: @transactable_type)
    get :index, transactable_type_id: @transactable_type.id
    assert_response :success
    assert_equal [@form_component], assigns(:form_components)
  end

  should '#new' do
    get :new, transactable_type_id: @transactable_type.id, form_type: 'space_wizard'
    assert_response :success
  end

  context 'create' do
    should 'create new form compponents' do
      assert_difference 'FormComponent.count' do
        post :create, transactable_type_id: @transactable_type.id, form_component: { name: 'My section', form_fields: ["location => address", "transactable => price"], form_type: FormComponent::SPACE_WIZARD }
      end
      form_component = assigns(:form_component)
      assert_equal 'My section', form_component.name
      assert_equal [{ 'location' => 'address'}, {'transactable' => 'price'}], form_component.form_fields
      assert_equal @transactable_type.id, form_component.form_componentable_id
      assert_equal FormComponent::SPACE_WIZARD, form_component.form_type
      assert_redirected_to instance_admin_manage_transactable_type_form_components_path(@transactable_type)
    end

    should 'render form if validation errors' do
      assert_no_difference 'FormComponent.count' do
        post :create, transactable_type_id: @transactable_type.id, form_component: { name: 'My section' }
      end
      assert_response :success
      assert_equal 'My section', assigns(:form_component).name
    end
  end

  should 'edit' do
    @form_component = FactoryGirl.create(:form_component)
    get :edit, transactable_type_id: @transactable_type.id, id: @form_component.id
    assert_response :success
  end

  context 'update' do

    setup do
      @form_component = FactoryGirl.create(:form_component)
    end

    should 'update form compponents' do
      assert_no_difference 'FormComponent.count' do
        put :update, transactable_type_id: @transactable_type.id, id: @form_component.id, form_component: { name: 'My section', form_fields: ["location => address", "transactable => price"], form_type: FormComponent::SPACE_WIZARD }
      end
      form_component = assigns(:form_component)
      form_component.reload
      assert_equal 'My section', form_component.name
      assert_equal [{ 'location' => 'address'}, {'transactable' => 'price'}], form_component.form_fields
      assert_equal @transactable_type.id, form_component.form_componentable_id
      assert_equal FormComponent::SPACE_WIZARD, form_component.form_type
      assert_redirected_to instance_admin_manage_transactable_type_form_components_path(@transactable_type)
    end

    should 'render form if validation errors' do
      assert_no_difference 'FormComponent.count' do
        put :update, transactable_type_id: @transactable_type.id, id: @form_component.id, form_component: { name: 'My section', form_type: '' }
      end
      assert_response :success
      form_component = assigns(:form_component)
      assert_equal 'My section', form_component.name
    end
  end

  should 'destroy' do
    @form_component = FactoryGirl.create(:form_component)
    assert_difference 'FormComponent.count', -1 do
      delete :destroy, transactable_type_id: @transactable_type.id, id: @form_component.id
    end
    assert_redirected_to instance_admin_manage_transactable_type_form_components_path(@transactable_type)
  end

end

