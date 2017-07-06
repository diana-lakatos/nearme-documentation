# frozen_string_literal: true
module ElasticIndexer
  class ImageUploaderSerializer < ActiveModel::Serializer
    self.root = false

    def attributes
      object.versions.each_with_object({}) do |(key, image), versions|
        image.extend ActiveModel::SerializerSupport

        versions[key] = ImageSerializer.new(image).as_json
      end
    end
  end

  class ImageSerializer < ActiveModel::Serializer
    self.root = false

    attributes :url, :version_name

    private

    def url
      object.url.presence || default_url
    end

    def default_url
      object.model.send(object.mounted_as).url(object.version_name)
    end
  end
end
