require 'test_helper'

class InstanceAdmin::Manage::ServiceTypesControllerTest < ActionController::TestCase

  setup do
    @instance = FactoryGirl.create(:instance)
    PlatformContext.any_instance.stubs(:instance).returns(@instance)
    @user = FactoryGirl.create(:user)
    @service_type = FactoryGirl.create(:transactable_type)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'update' do

    should 'store correctly custom csv fields' do
      put :update, id: @service_type.id, service_type: { custom_csv_fields: ['location=>email', 'address=>city' ] }
      assert_equal [{'location' => 'email'}, {'address' => 'city'}], @service_type.reload.custom_csv_fields
    end

  end

end
