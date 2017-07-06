# frozen_string_literal: true
module ElasticIndexer
  class TransactableTypeSerializer < BaseSerializer
    attributes :name, :parameterized_name
  end
end
