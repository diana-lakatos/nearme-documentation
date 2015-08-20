require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  should 'GET #index' do
    assert_equal Tag.count, 0
    
    blog_post = FactoryGirl.create(:user_blog_post, tag_list: "aaa,abb,abc,xyz")

    get :index, q: " "
    assert_equal 4, JSON.parse(response.body).length

    get :index, q: "a"
    assert_equal 3, JSON.parse(response.body).length

    get :index, q: "ab"
    assert_equal 2, JSON.parse(response.body).length

    get :index, q: "x"
    assert_equal 1, JSON.parse(response.body).length

    get :index
    assert_equal 0, JSON.parse(response.body).length
  end
end
