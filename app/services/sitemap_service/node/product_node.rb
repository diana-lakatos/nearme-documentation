class SitemapService::Node::ProductNode < SitemapService::Node
  def location
    url_helpers.product_path(@object.slug)
  end

  def changefreq
    "daily"
  end

  def image
    @image = @object.try(:images).try(:first).try(:image).try(:url)
  rescue
    nil
  end

  def self.comment_mark
    "products"
  end
end
