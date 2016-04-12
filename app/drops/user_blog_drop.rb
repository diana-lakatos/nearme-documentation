class UserBlogDrop < BaseDrop
  attr_reader :blog

  # name
  #   Blog's name
  delegate :name, to: :blog

  def initialize(blog)
    @blog = blog
  end

  # check if header icon is present
  def header_icon_present?
    @blog.header_icon.present?
  end

  # check if header logo is present
  def header_logo_present?
    @blog.header_logo.present?
  end

  # url for header icon image
  def header_icon_url
    @blog.header_icon.url
  end

  # url for header logo image
  def header_logo_url
    @blog.header_logo.url
  end

  # check if header image is present
  def header_image_present?
    @blog.header_image.present?
  end

  # url for header image
  def header_image_url
    @blog.header_image.url
  end

end
