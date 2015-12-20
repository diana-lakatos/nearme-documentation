require "test_helper"

class SessionsTest < ActionDispatch::IntegrationTest

  setup do
    @user = FactoryGirl.create(:user)
    @role = FactoryGirl.create(:instance_admin_role)
    @role.update_attribute(:permission_analytics, false)
    @role.update_attribute(:permission_settings, true)
    @instance_admin = FactoryGirl.create(:instance_admin, :user_id => @user.id)
    @instance_admin.update_attribute(:instance_owner, false)
    @instance_admin.update_attribute(:instance_admin_role_id, @role.id)
    instance = Instance.first
    instance.domains << FactoryGirl.create(:domain, name: "www.example.com")
  end

  test 'redirect to first page instance_admin has access to' do
    post_via_redirect user_session_path, user: { email: @user.email, password: @user.password }, return_to: instance_admin_path
    assert_equal instance_admin_settings_configuration_path, path
  end
end
