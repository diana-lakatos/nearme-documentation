require 'test_helper'

class BlogPostTest < ActiveSupport::TestCase
  context 'url slugging' do
    should 'keep the same slug on save if the title attribute did not change' do
      blog_post = FactoryGirl.create(:blog_post)
      original_slug = blog_post.slug
      blog_post.save!
      assert blog_post.slug == original_slug
    end

    should 'generate a new slug on save if the title attribute changed' do
      blog_post = FactoryGirl.create(:blog_post)
      original_slug = blog_post.slug
      blog_post.title = 'New Title'
      blog_post.save!
      assert blog_post.slug != original_slug
      assert blog_post.slug == 'new-title'
    end
  end
end
