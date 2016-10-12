require 'test_helper'

class Dashboard::UserBlog::BlogControllerTest < ActionController::TestCase
  context '#index' do
    setup do
      @user = FactoryGirl.create(:user)
      @company = FactoryGirl.create(:company, creator: @user)
      User.any_instance.stubs(:registration_completed?).returns(true)
      sign_in @user
      PlatformContext.current.instance.update_column(:user_blogs_enabled, true)
    end

    should 'redirect to dashboard if user blogging is disabled on instance' do
      PlatformContext.current.instance.update_column(:user_blogs_enabled, false)
      get :show
      assert_response :redirect
      assert_redirected_to dashboard_path
    end

    should 'display settings if user blogging is enabled on instance' do
      get :edit
      assert_response :ok
    end

    should 'display blog posts' do
      get :show
      assert_response :ok
    end

    should 'update blog settings' do
      name = 'My little pony blog'
      patch :update, user_blog: { name: name }
      assert_response :redirect
      assert_redirected_to edit_dashboard_blog_path
      assert_equal @user.blog.reload.name, name
    end
  end
end
