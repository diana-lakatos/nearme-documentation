# frozen_string_literal: true
module Elastic
  module Commands
  end
  class Engine
    def create_index(index)
      indices.create index: index.name, body: index.body
    end

    def find_index(alias_name)
      data = indices.get_alias index: alias_name

      IndexNameBuilder.load(data)
    end

    def index_exists?(alias_name)
      indices.exists index: alias_name
    end

    def switch_alias(from:, to:)
      SwitchAliases.new(from: from, to: to).perform
    end

    def import(index)
      index.type.sources.each do |source|
        ImportData.new(source, index).perform
      end
    end

    def cleanup_indices
    end

    def destroy!(index)
      indices.delete index: index.alias_name
    end

    private

    def indices
      client.indices
    end

    def client
      Elasticsearch::Model.client
    end
  end

  class ImportData
    attr_reader :source, :index
    def initialize(source, index)
      @source = source
      @index = index
    end

    def perform
      source.searchable.import batch_size: 50, index: index.name, transform: transform
    end

    private

    def transform
      return default_transform unless multiple_types?

      lambda do |model|
        {
          index: {
            _id: model.id,
            parent: model.__parent_id,
            data: model.__elasticsearch__.as_indexed_json
          }
        }
      end
    end

    def multiple_types?
      source.mapping.options.key? :_parent
    end

    def default_transform
      source.__elasticsearch__.__transform
    end
  end

  class SwitchAliases
    def initialize(from:, to:)
      @from = from
      @to = to
    end

    def perform
      connection.post '_aliases', options.to_json
    end

    private

    def connection
      client.transport.get_connection.connection
    end

    def options
      {
        actions:
          [
            {
              remove: { alias: @from.alias_name, index: @from.name }
            },
            {
              add: { alias: @to.alias_name, index: @to.name }
            }
          ]
      }
    end

    def client
      Elasticsearch::Model.client
    end
  end
end
