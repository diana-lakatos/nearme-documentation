class BlogInstanceDrop < BaseDrop
  # @return [BlogInstance]
  attr_reader :blog

  # @!method name
  #   the name of the blog instance
  #   @return (see BlogInstance#name)
  # @!method header_text
  #   the header text
  #   @return (see BlogInstance#header_text)
  # @!method header_motto
  #   the header motto
  #   @return (see BlogInstance#header_motto)
  # @!method facebook_app_id
  #   the Facebook App ID
  #   @return [String] blog's facebook_app_id
  # @!method header
  #   @return [HeroImageUploader] blog's header image uploader object
  delegate :name, :header_text, :header_motto, :facebook_app_id, :header, to: :blog

  def initialize(blog)
    @blog = blog
  end

  # url for header image
  # @return [String]
  def header_url
    header.present? ? header.url : nil
  end

  # is the header present
  # @return [Boolean]
  def header_present?
    header.present?
  end

  # check if header icon is present
  # @return [Boolean]
  def header_icon_present?
    @blog.header_icon.present?
  end

  # check if header logo is present
  # @return [Boolean]
  def header_logo_present?
    @blog.header_logo.present?
  end

  # check if header_text is present
  # @return [Boolean]
  def header_text_present?
    @blog.header_text.present?
  end

  # check if header_motto is present
  # @return [Boolean]
  def header_motto_present?
    @blog.header_motto.present?
  end

  # url for header icon image
  # @return [String]
  def header_icon_url
    @blog.header_icon.url
  end

  # url for header logo image
  # @return [String]
  def header_logo_url
    @blog.header_logo.url
  end

  # check if facebook_app_id is present
  # @return [Boolean]
  def facebook_app_id_present?
    @blog.facebook_app_id
  end

  # url for blog
  # @return [String]
  def blog_posts_path
    routes.blog_posts_path
  end
end
