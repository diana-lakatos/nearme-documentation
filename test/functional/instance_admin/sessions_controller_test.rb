require 'test_helper'

class InstanceAdmin::SessionsControllerTest < ActionController::TestCase
  setup do
    @controller = InstanceAdmin::SessionsController.new
    @user = FactoryGirl.create(:user)
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  should 'successfully sign up and track and redirected to instance admin' do
    post :create, { user: { email: @user.email, password: @user.password }, return_to: instance_admin_path }
    assert_redirected_to instance_admin_path
  end

  should 'be on instance admin login page after log out' do
    sign_in @user
    @request.env['HTTP_REFERER'] = '/instance_admin/pages'
    delete :destroy
    assert_redirected_to instance_admin_login_path
    assert_equal 'Signed out successfully.', flash[:notice]
  end
end
