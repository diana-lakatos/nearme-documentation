class BlogPost < ActiveRecord::Base

  belongs_to :blog_instance
  belongs_to :user # user who created this post

  validates_presence_of :blog_instance, :user, :title, :content

  def previous_blog_post
    @previous_blog_post ||= blog_instance.blog_posts.where('created_at < ?', created_at).first
  end

  def next_blog_post
    @next_blog_post ||= blog_instance.blog_posts.where('created_at > ?', created_at).last
  end

end
