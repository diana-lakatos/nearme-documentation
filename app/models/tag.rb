ActsAsTaggableOn::Tag.class_eval do
  auto_set_platform_context
  scoped_to_platform_context

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  belongs_to :instance

  scope :alphabetically, -> { order(name: :asc) }
  scope :by_query, -> (query) { where('name ILIKE ?', "%#{query}%") }
  scope :autocomplete, -> (query) { by_query(query).alphabetically }

  def to_liquid
    @tag_drop ||= TagDrop.new(self)
  end
end

Tag = ActsAsTaggableOn::Tag
