# frozen_string_literal: true
require 'test_helper'

class GlobalAdmin::DashboardControllerTest < ActionController::TestCase
  context 'non-admin user' do
    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    context 'GET show' do
      should 'not display and redirect to home page' do
        get :show
        assert_response :redirect
        assert_redirected_to root_url
      end
    end
  end
end
