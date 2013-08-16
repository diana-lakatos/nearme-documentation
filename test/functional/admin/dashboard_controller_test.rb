require 'test_helper'

class Admin::DashboardControllerTest < ActionController::TestCase

  context 'anonymous user' do
    context 'GET show' do
      should "not display and redirect to home page" do
        get :show
        assert_response :redirect
        assert_redirected_to new_user_session_url
      end
    end
  end

  context 'non-admin user' do
    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    context 'GET show' do
      should "not display and redirect to home page" do
        get :show
        assert_response :redirect
        assert_redirected_to root_url
      end
    end
  end

  context "admin user" do
    setup do
      @user = FactoryGirl.create(:user, :admin => true)
      sign_in @user
    end

    context 'GET show' do
      should "not display and redirect to home page" do
        get :show
        assert_response :success
      end
    end
  end
end

