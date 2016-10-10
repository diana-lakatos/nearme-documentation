require 'test_helper'

class UserBlogPostTest < ActiveSupport::TestCase
  context 'url slugging' do
    should 'keep the same slug on save if the title attribute did not change' do
      user_blog_post = FactoryGirl.create(:user_blog_post)
      original_slug = user_blog_post.slug
      user_blog_post.save!
      assert user_blog_post.slug == original_slug
    end

    should 'generate a new slug on save if the title attribute changed' do
      user_blog_post = FactoryGirl.create(:user_blog_post)
      original_slug = user_blog_post.slug
      user_blog_post.title = 'New Title'
      user_blog_post.save!
      assert user_blog_post.slug != original_slug
      assert user_blog_post.slug == 'new-title'
    end

    should 'generate a new slug on save if two posts have same title' do
      user_blog_post = FactoryGirl.create(:user_blog_post)
      taken_title = user_blog_post.title
      user_blog_post.save!

      new_user_blog_post = FactoryGirl.create(:user_blog_post)
      new_user_blog_post.title = taken_title
      new_user_blog_post.save!

      assert user_blog_post.slug != new_user_blog_post.slug
    end
  end
end
