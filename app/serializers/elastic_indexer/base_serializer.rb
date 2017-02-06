module ElasticIndexer
  class BaseSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id
  end
end
