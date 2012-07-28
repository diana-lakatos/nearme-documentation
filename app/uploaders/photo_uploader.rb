# encoding: utf-8
class PhotoUploader < BaseUploader

  def store_dir
    # Photos are polymorphic, so use that in the storage
    #"#{model.content.class.to_s.underscore}/#{model.content.id}/#{model.class.to_s.underscore}/#{model.id}/"

    # Remain compatible with existing uploads to S3
    # TODO: move existing uploads so we can using the polymorphic paths
    "uploads/photos/#{model.id}/"
  end

end
