require "test_helper"

class InstanceAdmin::AdminSessionsTest < ActionDispatch::IntegrationTest

  setup do
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:admin)
  end

  should 'test user access restrictions to instance admin panel' do
    post_via_redirect user_session_path, user: { email: @user.email, password: @user.password }, return_to: instance_admin_settings_configuration_path
    assert_equal root_path, path
    assert_equal I18n.translate('flash_messages.authorizations.not_authorized'), flash[:warning]
  end

  should 'test admin access to instance admin panel' do
    post_via_redirect user_session_path, user: { email: @admin.email, password: @admin.password }, return_to: instance_admin_settings_configuration_path
    assert_equal instance_admin_settings_configuration_path, path
  end
end
