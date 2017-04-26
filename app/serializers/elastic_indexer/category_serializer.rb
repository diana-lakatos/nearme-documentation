# frozen_string_literal: true
module ElasticIndexer
  class CategorySerializer < BaseSerializer
    attributes :root,
               :position,
               :name,
               :permalink

    def root
      # maciek says hi :)
      object.root&.name
    end
  end
end
