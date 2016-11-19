# frozen_string_literal: true
require 'test_helper'

class InstanceAdmin::Analytics::OverviewControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  end

  context 'GET #show' do
    should 'show listings from last 30 days' do
      @fresh_transactable = FactoryGirl.create(:transactable)
      @old_transactable = FactoryGirl.create(:transactable).update_column(:created_at, 32.days.ago)
      get :show, chart_type: 'listings'
      assert_response :success
      assert_equal(
        '[[0,0,0,0,0,0,1]]',
        assigns(:analytics).to_liquid.values
      )
    end
  end
end
