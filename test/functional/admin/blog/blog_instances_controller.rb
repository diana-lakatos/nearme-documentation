require 'test_helper'

class Admin::Blog::BlogInstancesControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user, admin: true)
    @blog_post = FactoryGirl.create(:blog_post)
    @blog_instance = @blog_post.blog_instance
    sign_in @user
  end

  should 'render edit' do
    get :edit
    assert_response :success
  end

  should 'update' do
    name = 'My Little bloge'
    post :update, blog_instance: { name: name }
    assert_equal @blog_instance.reload.name, name
  end
end
