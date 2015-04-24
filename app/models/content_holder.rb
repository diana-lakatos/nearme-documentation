class ContentHolder < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  class NotFound < ActiveRecord::RecordNotFound; end

  scope :enabled, -> { where(enabled: true) }

  belongs_to :theme
  belongs_to :instance

  after_validation :expire_cache
  after_destroy :expire_cache

  validates :name, uniqueness: { scope: :theme_id }

  def expire_cache
    Rails.cache.delete("theme.#{theme_id}.content_holders.#{name}")
    if name_changed?
      Rails.cache.delete("theme.#{theme_id}.content_holders.#{name_was}")
    end
  end

end