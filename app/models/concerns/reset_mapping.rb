module ResetMapping
  extend ActiveSupport::Concern

  included do |_base|
    def self.reset_mapping(*options)
      __elasticsearch__
        .instance_variable_set '@mapping', Elasticsearch::Model::Indexing::Mappings.new(document_type)

      build_es_mapping(*options)
    end
  end
end
