class Link < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :linkable, polymorphic: true

  validates_url :url, { no_local: true, schemes: %w(http https) }

  mount_uploader :image, LinkImageUploader

end

