module ElasticIndexer
  class ImageSerializer < ActiveModel::Serializer
    self.root = false

    attributes :url, :size, :version_name

    def url
      object.url.presence || default_url
    end

    def default_url
      object.url(object.version_name)
    end
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
