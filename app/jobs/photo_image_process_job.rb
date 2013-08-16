class PhotoImageProcessJob < Job
  def initialize(photo_id)
    @photo = Photo.find(photo_id)
  end

  def perform
    @photo.generate_versions
  end
end
