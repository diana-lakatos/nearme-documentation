require 'test_helper'

class InstanceAdmin::Settings::ConfigurationControllerTest < ActionController::TestCase

  context 'authorization' do
    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
      InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    end

    should 'end with success if user is authorized to view settings' do
      InstanceAdminAuthorizer.any_instance.stubs(:authorized?).at_least_once.returns(false)
      InstanceAdminAuthorizer.any_instance.stubs(:authorized?).with('Settings').returns(true)
      get :show
      assert_response :success
      assert_template :show
    end

    should 'redirect user to instance admin path if he is authorized for analytics' do
      InstanceAdminAuthorizer.any_instance.stubs(:authorized?).with('Analytics').returns(true)
      InstanceAdminAuthorizer.any_instance.stubs(:authorized?).with('Settings').returns(false)
      get :show
      assert_redirected_to instance_admin_analytics_path
    end

    should 'not end up in infinite loop if user has no access to analytics' do
      InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(false)
      get :show
      assert_redirected_to root_path
    end
  end

  context 'attributes' do
    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
      InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
      InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    end

    should 'update basic configureation and nomenclature' do
      post :update, "instance"=>{
                      "name"=>"New Instance Name",
                      "domains_attributes"=>{ "0"=>{"name"=>"example.org", "use_as_default" => "true"} }
                    }
      instance = assigns[:instance]
      assert_equal instance.name, "New Instance Name"
      assert_equal instance.default_domain.name, "example.org"
      assert_redirected_to instance_admin_settings_configuration_path
    end
  end
end
