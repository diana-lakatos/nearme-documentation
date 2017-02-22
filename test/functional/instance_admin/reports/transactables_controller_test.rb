require 'test_helper'

class InstanceAdmin::Reports::TransactablesControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  end

  should 'update transactable settings' do
    transactable = FactoryGirl.create(:transactable, photos_count: 1)

    put :update, id: transactable.id,
                 transactable: {
                   enabled: true
                 }
    assert transactable.reload.enabled

    put :update, id: transactable.id,
                 transactable: {
                   enabled: false
                 }
    refute transactable.reload.enabled
  end

  should 'delete transactable from reports' do
    transactable = FactoryGirl.create(:transactable, photos_count: 1)

    assert Transactable.exists?(transactable)

    delete :destroy, id: transactable.id

    refute Transactable.exists?(transactable)
  end

  should 'see transactable information' do
    transactable = FactoryGirl.create(:transactable, photos_count: 1)

    get :show, id: transactable.id

    assert_select 'th', 'Attribute'
    assert_select 'th', 'Value'
  end
end
