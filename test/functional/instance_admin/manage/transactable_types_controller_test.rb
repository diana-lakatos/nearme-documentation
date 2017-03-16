require 'test_helper'

class InstanceAdmin::Manage::TransactableTypesControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @transactable_type = FactoryGirl.create(:transactable_type)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'update' do
    should 'store correctly custom csv fields' do
      put :update, id: @transactable_type.id, transactable_type: { custom_csv_fields: ['location=>email', 'address=>city'] }
      assert_equal [{ 'location' => 'email' }, { 'address' => 'city' }], @transactable_type.reload.custom_csv_fields
    end
  end
end
