class PhotoSerializer < ApplicationSerializer

  attributes :id, :caption, :thumb_url, :medium_url, :large_url, :space_listing_url

  def caption
    object.caption || ""
  end

  def thumb_url
    object.image_url(:thumb)
  end

  def medium_url
    object.image_url(:medium)
  end

  def large_url
    object.image_url(:large)
  end

  def space_listing_url
    object.image_url(:space_listing)
  end

end
