# frozen_string_literal: true
class UserBlogDrop < BaseDrop
  # @return [UserBlogDrop]
  attr_reader :blog

  # @!method name
  #   Blog's name
  #   @return (see UserBlog#name)
  delegate :name, to: :blog

  def initialize(blog)
    @blog = blog
  end

  # @return [Boolean] whether the header icon is present
  # @todo - deprecate - DIY
  def header_icon_present?
    @blog.header_icon.present?
  end

  # @return [Boolean] whether the header logo is present
  # @todo - deprecate - DIY
  def header_logo_present?
    @blog.header_logo.present?
  end

  # @return [String] url for header icon image
  # @todo - deprecate - DIY
  def header_icon_url
    @blog.header_icon.url
  end

  # @return [String] url for header logo image
  # @todo - deprecate - DIY
  def header_logo_url
    @blog.header_logo.url
  end

  # @return [Boolean] whether the header image is present
  # @todo - deprecate - DIY
  def header_image_present?
    @blog.header_image.present?
  end

  # @return [String] url for header image
  # @todo - deprecate - DIY
  def header_image_url
    @blog.header_image.url
  end
end
