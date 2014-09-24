require 'test_helper'

class UserBlog::BlogControllerTest < ActionController::TestCase

  context '#index' do
    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end


    should 'redirect to 404 if user blogging is disabled on instance' do
      get :index
      assert_response :missing
    end

    should 'display settings if user blogging is enabled on instance' do
      PlatformContext.current.instance.update_column :user_blogs_enabled, true
      get :settings
      assert_response :ok
    end
  end
end
