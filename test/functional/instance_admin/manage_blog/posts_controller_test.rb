require 'test_helper'

class InstanceAdmin::ManageBlog::PostsControllerTest < ActionController::TestCase
  setup do
    @instance = FactoryGirl.create(:instance)
    PlatformContext.any_instance.stubs(:instance).returns(@instance)
    @blog_instance = FactoryGirl.create(:blog_instance, owner: @instance)
    @user = FactoryGirl.create(:user)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'index' do
    should 'show a listing of blog posts associated with current instance' do
      @blog_post = FactoryGirl.create(:blog_post, blog_instance: @blog_instance, title: 'Blog post')
      get :index
      assert_select 'td', 'Blog post'
    end
  end

  context 'create' do
    should 'create a new blog post' do
      assert_difference 'BlogPost.count', 1 do
        post :create, 'blog_post' => {
          'title' => 'Blog post',
          'content' => 'lorem ipsum',
          'published_at(1i)' => '2014',
          'published_at(2i)' => '6',
          'published_at(3i)' => '24'
        }
      end
      assert_equal 'Blog post', assigns(:blog_post).title
    end
  end

  context 'destroy' do
    should 'destroy blog post' do
      @blog_post = FactoryGirl.create(:blog_post, blog_instance: @blog_instance)
      assert_difference 'BlogPost.count', -1 do
        delete :destroy, id: @blog_post.id
      end
      assert_redirected_to instance_admin_manage_blog_posts_path
    end
  end
end
