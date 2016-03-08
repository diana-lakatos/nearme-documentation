# frozen_string_literal: true
require 'test_helper'

class Admin::UiSettingsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @controller.stubs(:current_user).returns(@user)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  end

  context '#index' do
    should 'fetch empty hash for new user' do
      get :index

      assert_equal 'success', json_response['result']
      assert_equal Hash.new, json_response['data']
    end
  end

  context '#get' do
    should 'get null for unset setting' do
      get :get, id: 'setting'

      assert_equal 'success', json_response['result']
      assert_equal nil, json_response['data']
    end

    should 'get value for set setting' do
      @user.set_ui_setting('setting', 'value')

      get :get, id: 'setting'

      assert_equal 'success', json_response['result']
      assert_equal 'value', json_response['data']
    end
  end

  context '#set' do
    should 'update ui setting' do
      post :set, id: 'setting', value: 'value'
      assert_equal 'value', @user.get_ui_setting('setting')
    end
  end

  private

  def json_response
    ActiveSupport::JSON.decode @response.body
  end
end
