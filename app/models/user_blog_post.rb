class UserBlogPost < ActiveRecord::Base
  belongs_to :user

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :history, :finders]

  mount_uploader :hero_image, HeroImageUploader
  mount_uploader :logo, BaseImageUploader

  validates :title, :published_at, :user, :content, presence: true

  scope :by_date, -> { order('published_at desc') }
  scope :published, -> { by_date.where('published_at < ? OR published_at IS NULL', Time.zone.now) }
  scope :recent, -> { published.first(2) }

  self.per_page = 5

  def previous_blog_post
    @previous_blog_post ||= user.blog_posts.published.order('published_at DESC').where('published_at < ?',
                                                                                                published_at).first
  end

  def next_blog_post
    @next_blog_post ||= user.blog_posts.published.order('published_at DESC').where('published_at > ?',
                                                                                            published_at).last
  end

  private

  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end

  def slug_candidates
    [:title]
  end
end
