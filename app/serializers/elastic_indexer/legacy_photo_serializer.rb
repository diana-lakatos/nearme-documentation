# frozen_string_literal: true
module ElasticIndexer
  class LegacyPhotoSerializer < BaseSerializer
    attributes :caption

    has_one :image, key: :versions, serializer: ImageUploaderSerializer
  end
end
