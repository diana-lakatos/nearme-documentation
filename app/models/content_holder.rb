class ContentHolder < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  has_paper_trail
  class NotFound < ActiveRecord::RecordNotFound; end

  ANY_PAGE = 'any_page'.freeze
  POSITIONS = [%w(Head meta), ['Head bottom', 'head_bottom'], ['Body top', 'body_top'], ['Body bottom', 'body_bottom']].freeze

  default_scope { order('LOWER(name)') }

  scope :enabled, -> { where(enabled: true) }
  scope :by_inject_pages, -> (path_group) { where('(? = ANY (inject_pages)) OR (? = ANY (inject_pages))', path_group, ANY_PAGE) }
  scope :no_inject_pages, -> { where("inject_pages = '{\"\"}' OR inject_pages = '{}'") }
  scope :no_position, -> (positions) { where('position is NULL or position NOT IN (?)', positions) }

  belongs_to :theme
  belongs_to :instance

  after_validation :expire_cache
  after_destroy :expire_cache

  validates :name, presence: true
  validates :content, liquid: true

  def expire_cache
    [name, name_was].each do |field|
      Rails.cache.delete("theme.#{theme_id}.content_holders.names.#{field}")
    end
    Rails.cache.delete_matched("theme.#{theme_id}.content_holders.paths.*")
  end

  def with_content_for
    if position.present?
      <<-LIQ
        {% content_for #{position} %}
          #{content}
        {% endcontent_for %}
      LIQ
    else
      content
    end
  end
end
