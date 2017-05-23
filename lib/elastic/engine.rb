# frozen_string_literal: true
module Elastic
  class Engine
    def create_index(index)
      indices.create index: index.name, body: index.body
    end

    def index_exists?(name)
      indices.exists index: name
    end

    def destroy!(name)
      indices.delete index: name
    end

    def find_index(name)
      Elastic::Commands::FindIndex.new(name: name).perform
    end

    def switch_alias(from:, to:)
      Elastic::Commands::SwitchAlias.new(from: from, to: to).perform
    end

    def add_alias(index:, alias_name:)
      Elastic::Commnads::AddAlias.new(index: index, alias_name: alias_name).perform
    end

    def import(index:, doc_types:)
      doc_types.each do |_name, doc_type|
        Elastic::Commands::Import.new(doc_type: doc_type, index: index).perform
      end
    end

    def refresh(from:, to:)
      Elastic::Commands::Refresh.new(from: from, to: to).perform
    end

    def cleanup_indices
    end

    private

    def indices
      client.indices
    end

    def client
      Elasticsearch::Model.client
    end
  end
end
