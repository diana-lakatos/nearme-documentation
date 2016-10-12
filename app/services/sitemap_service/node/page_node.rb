class SitemapService::Node::PageNode < SitemapService::Node
  def location
    url_helpers.pages_path(@object)
  end

  def image
    @image = @object.hero_image.try(:url)
    super
  end

  def self.comment_mark
    'pages'
  end
end
