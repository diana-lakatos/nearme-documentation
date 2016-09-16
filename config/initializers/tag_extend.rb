ActsAsTaggableOn::Tag.class_eval do
  auto_set_platform_context
  scoped_to_platform_context

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders, :scoped], scope: :instance

  belongs_to :instance

  validates_uniqueness_of :name, scope: [:instance_id]

  scope :alphabetically, -> { order(name: :asc) }
  scope :by_query, -> (query) { where('name ILIKE ?', "%#{query}%") }
  scope :autocomplete, -> (query) { by_query(query).alphabetically }
  scope :for_instance_blog, -> { includes(:taggings).where(taggings: { taggable_type: 'BlogPost' } ) }

  def to_liquid
    @tag_drop ||= TagDrop.new(self)
  end

  def validates_name_uniqueness?
    false
  end
end

Tag = ActsAsTaggableOn::Tag
