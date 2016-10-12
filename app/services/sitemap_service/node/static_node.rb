class SitemapService::Node::StaticNode < SitemapService::Node
  def location
    @object
  end

  def changefreq
    'monthly'
  end

  def self.comment_mark
    'root'
  end
end
