class SitemapService::Node::TransactableNode < SitemapService::Node
  def location
    url_helpers.location_path(@object.location.slug, listing_id: @object.id)
  end

  def changefreq
    "daily"
  end

  def image
    @object.photos.first.try(:image).try(:url)
  end

  def self.comment_mark
    "transactables"
  end
end
