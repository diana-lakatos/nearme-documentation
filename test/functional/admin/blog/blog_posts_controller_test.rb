require 'test_helper'

class Admin::Blog::BlogPostsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user, admin: true)
    @blog_post = FactoryGirl.create(:blog_post)
    sign_in @user
  end

  should 'render #index' do
    get :index
    assert_response :success
    assert_equal assigns(:blog_posts), [@blog_post]
  end

  should 'render #new' do
    get :new
    assert_response :success
  end

  should '#create' do
    blog_params = FactoryGirl.attributes_for(:blog_post)
    assert_difference('BlogPost.count') do
      post :create, blog_post: blog_params
    end
    assert_response :redirect
    assert_redirected_to admin_blog_blog_posts_path
  end

  should 'render #edit' do
    get :edit, id: @blog_post.id
    assert_response :success
  end

  should '#update' do
    content = 'I love turtles!'
    put :update, id: @blog_post.id, blog_post: { content: content }
    assert_response :redirect
    assert_redirected_to admin_blog_blog_posts_path
    assert_equal @blog_post.reload.content, content
  end

  should '#delete' do
    assert_difference('BlogPost.count', -1) do
      delete :destroy, id: @blog_post.id
    end
    assert_response :redirect
    assert_redirected_to admin_blog_blog_posts_path
  end
end
