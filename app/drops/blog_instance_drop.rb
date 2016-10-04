class BlogInstanceDrop < BaseDrop
  attr_reader :blog

  # name
  #   Blog's name
  # header_text
  #   Blog's header text
  # header_motto
  #   Blog's header motto
  # facebook_app_id
  #   Blog's facebook_app_id
  # header
  #   Blog's header image
  delegate :name, :header_text, :header_motto, :facebook_app_id, :header, to: :blog

  def initialize(blog)
    @blog = blog
  end

  # url for header image
  def header_url
    header.present? ? header.url : nil
  end

  def header_present?
    header.present?
  end

  # check if header icon is present
  def header_icon_present?
    @blog.header_icon.present?
  end

  # check if header logo is present
  def header_logo_present?
    @blog.header_logo.present?
  end

  # check if header_text is present
  def header_text_present?
    @blog.header_text.present?
  end

  # check if header_motto is present
  def header_motto_present?
    @blog.header_motto.present?
  end

  # url for header icon image
  def header_icon_url
    @blog.header_icon.url
  end

  # url for header logo image
  def header_logo_url
    @blog.header_logo.url
  end

  # check if facebook_app_id is present
  def facebook_app_id_present?
    @blog.facebook_app_id
  end

  # url for blog
  def blog_posts_path
    routes.blog_posts_path
  end

end
