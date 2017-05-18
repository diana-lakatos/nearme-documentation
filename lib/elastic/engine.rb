# frozen_string_literal: true
module Elastic
  module Commands
  end
  class Engine
    def create_index(index)
      indices.create index: index.name, body: index.body
    end

    def find_index(name)
      data = indices.get index: name

      data.any? && IndexNameBuilder.load(data)
    end

    def index_exists?(alias_name)
      indices.exists index: alias_name
    end

    def switch_alias(from:, to:)
      SwitchAliases.new(from: from, to: to).perform
    end

    def add_alias(index:, alias_name:)
      AddAliasToIndex.new(index: index, alias_name: alias_name).perform
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
      print_import_details
      scoped_source.import batch_size: 50, index: index.name, transform: transform
    end

    def print_import_details
      puts format('Importing %d items from %s', scoped_source.count, source.to_s)
    end

    private

    def scoped_source
      source.with_deleted.searchable
    end

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

  class AddAliasToIndex
    def initialize(index:, alias_name:)
      @index = index
      @alias_name = alias_name
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
              add: { alias: @alias_name, index: @index.name }
            }
          ]
      }
    end

    def client
      Elasticsearch::Model.client
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
