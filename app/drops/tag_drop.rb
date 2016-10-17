class TagDrop < BaseDrop

  # @return [ActsAsTaggableOn::Tag]
  attr_reader :tag

  # @!method name
  #   Name of the tag
  #   @return (see Tag#name)
  # @!method slug
  #   URL-friendly name for the tag
  #   @return (see Tag#slug)
  # @!method taggings_count
  #   Number of times this tag was tagged for this Marketplace
  #   @return (see Tag#taggings_count)
  delegate :name, :slug, :taggings_count, to: :tag

  def initialize(tag)
    @tag = tag
  end

  # @return [String] tag name
  def to_s
    @tag.name
  end

end
