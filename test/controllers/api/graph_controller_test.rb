# frozen_string_literal: true
require 'test_helper'

class Api::GraphControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @controller.stubs(:current_user).returns(@user)
    sign_in @user
  end

  test 'should execute the graphql query' do
    post :create, query: '{ __schema }', format: :json

    assert_response :success
  end
end
