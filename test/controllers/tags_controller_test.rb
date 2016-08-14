require 'test_helper'

class TagsControllerTest < ActionController::TestCase

  def setup
    @blog_post1 = create(:user_blog_post, tag_list: ['aaa, abb, abc, xyz'])
    @blog_post2 = create(:user_blog_post, tag_list: ['one, two, trhee'])
  end

  def test_returns_tags_by_query
    user = @blog_post1.user

    get :index, q: " ", user_id: user
    assert_equal 7, JSON.parse(response.body).length

    get :index, q: 'a', user_id: user
    assert_equal 3, JSON.parse(response.body).length

    get :index, q: 'ab', user_id: user
    assert_equal 2, JSON.parse(response.body).length

    get :index, q: 'x', user_id: user
    assert_equal 1, JSON.parse(response.body).length

    get :index, user_id: user
    assert_equal 0, JSON.parse(response.body).length
  end

  def test_returns_tags_within_users_scope
    user = @blog_post2.user
    get :index, q: " ", user_id: user

    assert_equal 7, JSON.parse(response.body).length
  end

end
