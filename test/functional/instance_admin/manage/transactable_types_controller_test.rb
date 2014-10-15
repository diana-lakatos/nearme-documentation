require 'test_helper'

class InstanceAdmin::Manage::TransactableTypesControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @instance = FactoryGirl.create(:instance)
    PlatformContext.any_instance.stubs(:instance).returns(@instance)
    @transactable_type = FactoryGirl.create(:transactable_type)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'show' do

    should 'show a list of transactable type attributes associated with current instance' do
      @tta = FactoryGirl.create(:custom_attribute, target: @transactable_type, name: 'my_custom_attribute')
      get :show, id: @transactable_type.id
      assert_select 'tr td', "My custom attribute"
    end
  end

end
