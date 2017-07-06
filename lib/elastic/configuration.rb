# frozen_string_literal: true
require 'yaml'
require 'addressable'

module Elastic
  class Configuration
    delegate :to_h, to: :config
    delegate :[], to: :config

    cattr_accessor :configuration

    def self.current
      raise 'ES configuration did not set properly' unless configuration
      configuration
    end

    def self.set(type:, instance_id:)
      self.configuration = Elastic::Configuration.new(type: type, instance_id: instance_id)
    end

    def initialize(type:, instance_id:)
      @index_type = type
      @instance_id = instance_id
    end

    def index_name(version: 'alias')
      Elastic::Configuration::IndexName
        .new(template: config['index']['template'])
        .expand(id: @instance_id, version: version)
    end

    def client
      Elasticsearch::Model.client
    end

    def doc_types
      config['doc_types'].each_with_object({}) do |(name, doc_type), memo|
        memo[name] = DocType.new(name, doc_type)
      end
    end

    def config
      YAML.load(file)
    end

    private

    def file
      File.open(File.join(ENV['PWD'], 'config', 'indices', "#{@index_type.to_s.parameterize}.yml"))
    rescue Errno::ENOENT
      File.open(File.join(ENV['PWD'], 'config', 'indices', 'default.yml'))
    end

    class IndexName
      def initialize(template:)
        @template = template
      end

      def params
        {
          env: ENV['RAILS_ENV'] || 'development',
          application_name: ENV['APPLICATION_NAME'],
          stack_name: ENV['STACK_NAME']
        }
      end

      def expand(id:, version:)
        Addressable::Template.new(@template).expand(params.merge(id: id, version: version)).to_s
      end
    end

    class DocType
      attr_reader :name

      def initialize(name, data)
        @name = name
        @data = data
      end

      def parent
        @data['parent_id']
      end

      def scope
        @data['scope']
      end

      def source
        @source ||= @data['source'].constantize
      end

      # TODO: isn't pointless keeping dynamic mapping configuration in the code?
      def mapping
        source.build_es_mapping(options: @data['mapping']['options'])

        source.mappings
      end
    end
  end
end
