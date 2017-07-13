# frozen_string_literal: true
module Elastic
  module InstanceDocuments
    class Base
      def initialize(instance_id)
        @instance_id = instance_id
      end

      def perform
        instance.set_context!
        ensure_index_zero_exists
        create_new_index
        import_data
        switch_aliases
      end

      private

      def ensure_index_zero_exists
        return if index_exists? configuration.index_name

        engine.create_index factory.build(version: 0)
      end

      def create_new_index
        if index_exists? new_index.name
          current = engine.find_index new_index.name

          # index exists and has not alias attached
          unless current.body.dig(:aliases, new_index.alias_name)
            engine.destroy! new_index.name
            engine.create_index new_index
          end
        else
          engine.create_index new_index
        end
      end

      def import_data
        engine.import index: new_index, doc_types: configuration.doc_types
      end

      def index_exists?(name)
        engine.index_exists?(name)
      end

      def switch_aliases
        engine.switch_alias from: current_index, to: new_index
      end

      def instance
        @instance ||= Instance.find(@instance_id)
      end

      def engine
        @engine ||= Elastic::Engine.new
      end

      def current_index
        @current_index ||= engine.find_index(configuration.index_name)
      end

      def new_index
        @new_index ||= factory.build(version: current_index.version.next)
      end

      def factory
        @factory ||= Elastic::Factory.new(config: configuration)
      end

      def configuration
        Elastic::Configuration.current
      end
    end

    class Rebuild < Base
    end

    class Refresh < Base
      def import_data
        engine.refresh from: current_index.name, to: new_index.name
      end
    end
  end
end
