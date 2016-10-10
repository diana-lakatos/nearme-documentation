require 'test_helper'

class Blog::BlogPostsControllerTest < ActionController::TestCase
  context '#show' do
    setup do
      @blog_post = FactoryGirl.create(:blog_post)
      @user_blog_post = FactoryGirl.create(:highlighted_user_blog_post)
    end

    context 'user highlighted blog post' do
      should 'be present on list' do
        get :index
        assert assigns(:blog_posts).include?(@user_blog_post)
        assert :success
      end

      should 'be viewable' do
        get :show, id: @user_blog_post
        assert_equal assigns(:blog_post), @user_blog_post
        assert :success
      end
    end

    should 'show list index' do
      get :index
      assert :success
    end

    should 'show blog post' do
      get :show, id: @blog_post
      assert_equal assigns(:blog_post), @blog_post
      assert :success
    end

    should 'redirect if old slug is used' do
      @slug = @blog_post.slug
      @blog_post.update_attribute(:slug, 'updated-title')
      get :show, id: @slug
      assert_response :moved_permanently
      assert_redirected_to blog_post_path(@blog_post)
    end
  end
end
