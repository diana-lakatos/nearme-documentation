require 'test_helper'

class Dashboard::UserBlog::BlogPostsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @company = FactoryGirl.create(:company, creator: @user)
    User.any_instance.stubs(:registration_completed?).returns(true)
    sign_in @user
    PlatformContext.current.instance.update_column(:user_blogs_enabled, true)
  end

  context 'with existing blog post' do
    setup do
      @blog = FactoryGirl.create(:user_blog_post, user: @user)
    end

    context '#edit' do
      should 'render form' do
        get :edit, id: @blog.id
        assert_response :success
      end
    end

    context '#update' do
      should 'update' do
        title = 'updated title'
        put :update, id: @blog.id, user_blog_post: { title: title }
        assert_equal @blog.reload.title, title
      end
    end

    context '#destroy' do
      should 'destroy' do
        assert_difference('@user.blog_posts.count', -1) do
          delete :destroy, id: @blog.id
        end
        assert_response :redirect
        assert_redirected_to dashboard_blog_path
      end
    end
  end

  context '#new' do
    should 'render' do
      get :new
      assert_response :success
    end

    should 'redirect to dashboard if user blogging is disabled on instance' do
      PlatformContext.current.instance.update_column(:user_blogs_enabled, false)
      get :new
      assert_response :redirect
      assert_redirected_to dashboard_path
    end
  end

  context '#create' do
    should 'create new blog post' do
      params = FactoryGirl.attributes_for(:user_blog_post)
      assert_difference('@user.blog_posts.count') do
        post :create, user_blog_post: params
      end
      assert_response :redirect
      assert_redirected_to dashboard_blog_path
    end
  end
end
