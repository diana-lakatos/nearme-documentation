require 'test_helper'

class InstanceAdmin::ManageBlog::UserPostsControllerTest < ActionController::TestCase
  setup do
    @instance = FactoryGirl.create(:instance)
    @user = FactoryGirl.create(:user)
    PlatformContext.current.instance.update_column(:user_blogs_enabled, true)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'index' do
    should 'show a listing of user blog posts' do
      @blog_post = FactoryGirl.create :user_blog_post, title: 'Blog post'
      get :index
      assert_select 'td', 'Blog post'
    end
  end

  context 'update' do
    should 'change user blog post' do
      @user_blog_post = FactoryGirl.create :user_blog_post
      assert_difference 'UserBlogPost.highlighted.count' do
        patch :update, id: @user_blog_post.id, 'user_blog_post' => { highlighted: true, title: 'New title' }
      end

      assert_equal 'New title', assigns(:blog_post).title
    end
  end

  context 'destroy' do
    should 'destroy blog post' do
      @user_blog_post = FactoryGirl.create(:user_blog_post)

      assert_difference 'UserBlogPost.count', -1 do
        delete :destroy, id: @user_blog_post.id
      end

      assert_redirected_to instance_admin_manage_blog_user_posts_path
    end
  end
end
