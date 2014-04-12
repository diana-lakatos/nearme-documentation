require 'test_helper'

class Blog::BlogPostsControllerTest < ActionController::TestCase

  context '#show' do
    setup do
      @blog_post = FactoryGirl.create(:blog_post)
    end

    should 'show blog post' do
      get :show, :id => @blog_post
      assert :success
    end

    should 'redirect if old slug is used' do
      @slug = @blog_post.slug
      @blog_post.update_attribute(:slug, 'updated-title')
      get :show, :id => @slug
      assert_response :moved_permanently
      assert_redirected_to blog_post_path(@blog_post)
    end

  end

end

