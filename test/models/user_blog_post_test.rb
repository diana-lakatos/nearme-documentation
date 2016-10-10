require 'test_helper'

class UserBlogPostTest < ActiveSupport::TestCase
  setup do
    @user_blog_post = UserBlogPost.new
  end

  def test_published_at
    I18n.stubs(:t).with('datepicker.dformat').returns('%m/%d/%Y')
    @user_blog_post.published_at = Date.parse('2016-04-28')

    assert_equal @user_blog_post.published_at_str, '04/28/2016'
  end

  def test_published_at=
    I18n.stubs(:t).with('datepicker.dformat').returns('%m/%d/%Y')
    @user_blog_post.published_at_str = '04/28/2016'

    assert_equal @user_blog_post.published_at, Date.parse('2016-04-28')
  end
end
