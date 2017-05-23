# frozen_string_literal: true
module ElasticIndexer
  class CustomAttachmentSerializer < BaseSerializer
    attributes :name, :label, :file_name

    delegate :file, to: :object
    delegate :custom_attribute, to: :object
    delegate :name, :label, to: :custom_attribute

    private

    def file_name
      object.attributes['file']
    end
  end
end
