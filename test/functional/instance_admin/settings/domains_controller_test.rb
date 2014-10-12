
require 'test_helper'

class InstanceAdmin::Settings::DomainsControllerTest < ActionController::TestCase
  context 'attributes' do
    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
      InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
      InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
      @domain = FactoryGirl.create(:domain)
    end

    should 'show list' do
      post :index
      assert_response :success
      assert_template :index
      assert_equal assigns[:domains], [@domain]
    end

    should 'new' do
      get :new
      assert_response :success
      assert_template :new
      assert_kind_of Domain, assigns[:domain]
      refute assigns[:domain].persisted?
    end

    should 'create' do
      assert_difference("Domain.count") {
        post :create, domain: {"name" => 'example.com'}
        assert_response :redirect
        assert_redirected_to instance_admin_settings_domains_path
      }
    end

    should 'update' do
      name = 'newname.com'
      put :update, id: @domain.id.to_s, domain: {'name' => name}
      assert_response :redirect
      assert_redirected_to instance_admin_settings_domains_path
      assert_equal @domain.reload.name, name
    end

    should 'delete' do
      new_domain = FactoryGirl.create(:domain)
      assert_difference("Domain.count", -1) {
        delete :destroy, id: new_domain.id.to_s
        assert_response :redirect
        assert_redirected_to instance_admin_settings_domains_path
      }
    end
  end
end
