class UserBlogDrop < BaseDrop

  # @return [UserBlog]
  attr_reader :blog

  # @!method name
  #   Blog's name
  #   @return (see UserBlog#name)
  delegate :name, to: :blog

  def initialize(blog)
    @blog = blog
  end

  # @return [Boolean] whether the header icon is present
  def header_icon_present?
    @blog.header_icon.present?
  end

  # @return [Boolean] whether the header logo is present
  def header_logo_present?
    @blog.header_logo.present?
  end

  # @return [String] url for header icon image
  def header_icon_url
    @blog.header_icon.url
  end

  # @return [String] url for header logo image
  def header_logo_url
    @blog.header_logo.url
  end

  # @return [Boolean] whether the header image is present
  def header_image_present?
    @blog.header_image.present?
  end

  # @return [String] url for header image
  def header_image_url
    @blog.header_image.url
  end
end
