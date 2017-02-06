module ElasticIndexer
  class CategorySerializer < BaseSerializer
    attributes :root,
               :position,
               :name,
               :permalink

    def root
      object.root && object.root.name
    end
  end
end
