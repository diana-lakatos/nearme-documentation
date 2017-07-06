module Elastic
  class IndexerHelper
    def initialize(klass)
      @klass = klass
      @es_indices = @klass.__elasticsearch__.client.indices
    end

    def create_base_index(check_alias: false)
      if !@es_indices.exists(index: @klass.base_index_name) && (!check_alias || !@es_indices.exists_alias(name: @klass.alias_index_name))
        @es_indices.create index: @klass.base_index_name, body: { settings: @klass.settings, mappings: @klass.mappings }
      end
    end

    def update_mapping!
      @es_indices.put_mapping index: @klass.index_name, type: @klass.to_s.demodulize.downcase, body: @klass.mappings
    end

    def create_alias(index_name = nil)
      unless @es_indices.exists_alias name: @klass.alias_index_name
        @es_indices.put_alias index: index_name || @klass.base_index_name, name: @klass.alias_index_name
      end
    end

    def delete_alias(index_name = @klass.base_index_name, alias_name = @klass.alias_index_name)
      @es_indices.delete_alias index: index_name, name: alias_name if @es_indices.exists_alias name: alias_name
    end

    def get_current_index_name
      @es_indices.get_alias(name: @klass.alias_index_name).keys.first
    end

    def create_new_index
      @new_index_name = "#{@klass.base_index_name}-#{Time.now.to_i}"
      @es_indices.create index: @new_index_name, body: { settings: @klass.settings, mappings: @klass.mappings }
      @new_index_name
    end

    def with_alias
      unless @es_indices.exists_alias name: @klass.alias_index_name
        @es_indices.put_alias index: @klass.base_index_name, name: @klass.alias_index_name
      end
      es_alias = @es_indices.get_alias name: @klass.alias_index_name
      @old_index_name = es_alias.keys.first
      create_new_index

      yield @new_index_name, @old_index_name

      update_alias
      if @es_indices.exists_alias(name: @klass.alias_index_name) && @es_indices.get_alias(name: @klass.alias_index_name).keys.first == @new_index_name
        @es_indices.delete index: @old_index_name
      else
        @es_indices.put_settings index: @old_index_name, body: { index: { "blocks.write": false } }
      end
    end

    def update_alias
      @klass.__elasticsearch__.client.transport.get_connection.connection.post \
        '_aliases',
        {
          actions: [
            { remove:
              {
                alias: @klass.alias_index_name,
                index: @old_index_name
              } },
            { add:
              {
                alias: @klass.alias_index_name,
                index: @new_index_name
              } }
          ]
        }.to_json
    end
  end
end
