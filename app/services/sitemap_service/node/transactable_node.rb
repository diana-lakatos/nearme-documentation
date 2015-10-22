class SitemapService::Node::TransactableNode < SitemapService::Node
  def location
    url_helpers.location_path(@object.try(:location).try(:slug), listing_id: @object.try(:slug))
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
