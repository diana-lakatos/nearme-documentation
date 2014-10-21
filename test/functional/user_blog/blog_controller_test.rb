require 'test_helper'

class UserBlog::BlogControllerTest < ActionController::TestCase

  context '#index' do
    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
      PlatformContext.current.instance.update_column(:user_blogs_enabled, true)
    end


    should 'redirect to 404 if user blogging is disabled on instance' do
      PlatformContext.current.instance.update_column(:user_blogs_enabled, false)
      get :index
      assert_response :missing
    end

    should 'display settings if user blogging is enabled on instance' do
      get :settings
      assert_response :ok
    end

    should 'display blog posts' do
      get :index
      assert_response :ok
    end

    should 'update blog settings' do
      name = 'My little ponny bloge'
      patch :update_settings, user_blog: {name: name}
      assert_response :redirect
      assert_redirected_to user_blog_path
      assert_equal @user.blog.reload.name, name
    end
  end
end
