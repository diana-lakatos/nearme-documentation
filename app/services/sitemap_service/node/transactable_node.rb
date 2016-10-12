class SitemapService::Node::TransactableNode < SitemapService::Node
  def location
    @object.try(:decorate).try(:show_path)
  end

  def changefreq
    'daily'
  end

  def image
    @object.photos.first.try(:image).try(:url)
  end

  def self.comment_mark
    'transactables'
  end
end
