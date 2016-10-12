require 'test_helper'

class InstanceAdmin::Settings::IntegrationsControllerTest < ActionController::TestCase
  context 'attributes' do
    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
      InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
      InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    end

    should 'update olark settings' do
      post :update, 'instance' => {
        'olark_api_key' => '1234-123-12-1234',
        'olark_enabled' => true
      }
      assert_redirected_to instance_admin_settings_integrations_path
      instance = assigns[:instance]
      assert_equal instance.olark_api_key, '1234-123-12-1234'
      assert_equal instance.olark_enabled?, true
    end

    should 'require olark api key if olark enabled is checked' do
      post :update, 'instance' => {
        'olark_enabled' => true
      }
      assert_response :success
      assert_equal "Olark api key can't be blank", flash[:error]
    end
  end
end
