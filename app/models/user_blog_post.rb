class UserBlogPost < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :history, :finders]

  include Taggable

  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user

  mount_uploader :hero_image, HeroImageUploader
  mount_uploader :author_avatar_img, AuthorAvatarUploader

  validates :title, :published_at, :user, :content, presence: true
  validates :title, :slug, length: { maximum: 255 }

  scope :by_date, -> { order('published_at desc') }
  scope :published, -> { by_date.where('published_at < ? OR published_at IS NULL', Time.zone.now) }
  scope :recent, -> { published.first(2) }
  scope :highlighted, -> { where(highlighted: true) }
  scope :not_highlighted, -> { where(highlighted: false) }

  self.per_page = 5

  def author_avatar
    if author_avatar_img.present?
      author_avatar_img
    else
      user.avatar
    end
  end

  # @return [UserBlogPost] the previously published user blog post
  def previous_blog_post
    @previous_blog_post ||= user.blog_posts.published.order('published_at DESC').where('published_at < ?',
                                                                                       published_at).first
  end

  # @return [UserBlogPost] the next published user blog post
  def next_blog_post
    @next_blog_post ||= user.blog_posts.published.order('published_at DESC').where('published_at > ?',
                                                                                   published_at).last
  end

  def to_liquid
    @user_blog_post_drop ||= UserBlogPostDrop.new(self)
  end

  def published?
    published_at <= Time.zone.now
  end

  def published_at_str
    published_at.try(:strftime, I18n.t('datepicker.dformat'))
  end

  def published_at_str=(value)
    value = Date.strptime(value, I18n.t('datepicker.dformat'))
    write_attribute(:published_at, value)
  end

  private

  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end

  def slug_candidates
    [
      :title,
      [:title, self.class.last.try(:id).to_i + 1],
      [:title, rand(1_000_000)]
    ]
  end
end
