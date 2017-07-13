# frozen_string_literal: true
module ElasticIndexer
  class CustomAttachmentSerializer < BaseSerializer
    attributes :name, :label, :file_name, :created_at, :size_bytes, :content_type

    delegate :file, :created_at, to: :object
    delegate :custom_attribute, to: :object
    delegate :name, :label, to: :custom_attribute

    private

    def file_name
      object.attributes['file']
    end

    def size_bytes
      object.file.file.size
    end

    def content_type
      object.file.file.content_type
    end
  end
end
