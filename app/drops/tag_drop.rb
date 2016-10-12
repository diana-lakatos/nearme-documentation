class TagDrop < BaseDrop
  attr_reader :tag

  # name
  #   Tag's name
  # slug
  #   A friendly name given to a tag
  # taggings_count
  #   Amount of times this tag was tagged for this Marketplace

  delegate :name, :slug, :taggings_count, to: :tag

  def initialize(tag)
    @tag = tag
  end

  def to_s
    @tag.name
  end
end
