# frozen_string_literal: true
class TagDrop < BaseDrop
  # @return [TagDrop]
  attr_reader :tag

  # @!method name
  #   @return [String] Name of the tag
  # @!method slug
  #   @return [String] URL-friendly name for the tag
  # @!method taggings_count
  #   @return [Integer] Number of times this tag was tagged for this Marketplace
  delegate :name, :slug, :taggings_count, to: :tag

  def initialize(tag)
    @tag = tag
  end

  # @return [String] tag name
  def to_s
    @tag.name
  end
end
