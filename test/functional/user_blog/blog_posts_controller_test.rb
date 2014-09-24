require 'test_helper'

class UserBlog::BlogPostsControllerTest < ActionController::TestCase

  context '#new' do
    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    should 'redirect to 404 if user blogging is disabled on instance' do
      get :new
      assert_response :missing
    end
  end
end
