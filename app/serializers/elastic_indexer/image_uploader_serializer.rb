module ElasticIndexer
  class ImageSerializer < ActiveModel::Serializer
    self.root = false

    attributes :url, :size, :image
  end

  class ImageUploaderSerializer < ActiveModel::Serializer
    self.root = false

    def attributes
      object.versions.each_with_object({}) do |(key, image), versions|
        image.extend ActiveModel::SerializerSupport

        versions[key] = ImageSerializer.new(image).as_json
      end
    end
  end
end
