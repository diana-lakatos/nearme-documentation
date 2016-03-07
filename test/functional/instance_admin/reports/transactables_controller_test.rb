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

    put :update, { id: transactable.id,
                   transactable: {
                   enabled: true
                   }
                 }
    assert_equal true, transactable.reload.enabled

    put :update, { id: transactable.id,
                   transactable: {
                   enabled: false
                   }
                 }
    assert_equal false, transactable.reload.enabled
  end

  should 'delete transactable from reports' do
    transactable = FactoryGirl.create(:transactable, photos_count: 1)

    assert_equal true, Transactable.exists?(transactable)

    delete :destroy, { id: transactable.id }

    assert_equal false, Transactable.exists?(transactable)
  end

  should 'see transactable information' do
    transactable = FactoryGirl.create(:transactable, photos_count: 1)

    get :show, { id: transactable.id }

    assert_select 'th', 'Attribute'
    assert_select 'th', 'Value'
  end

end

