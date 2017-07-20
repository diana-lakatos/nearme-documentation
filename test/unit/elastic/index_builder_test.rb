require 'test_helper_lite'
require 'elasticsearch'
require 'elasticsearch/model'
require 'active_support'
require 'ostruct'
require './lib/elastic.rb'
require './lib/elastic/configuration.rb'
require './lib/elastic/commands.rb'
require './lib/elastic/commands/find_index.rb'
require './lib/elastic/commands/switch_alias.rb'
require './lib/elastic/index_factory.rb'
require './lib/elastic/engine.rb'
require './lib/elastic/index.rb'

module Elastic
  class ConfigurationTest < ActiveSupport::TestCase

    test 'configuration' do

      Elastic::Configuration.new(type: :default, instance_id: 1).tap do |cfg|
        assert_equal cfg.doc_types.size, 2
        assert_equal cfg.doc_types.keys, [:user, :transactable].map(&:to_s)
      end
    end
  end

  module Fixtures
    def self.mappings
      {
        user: [%w(id), %w(id name), %w(id name slug current_address)],
        transactable: [%w(id transactable_type), %w(id name slug), %w(id name slug pricing)]
      }
    end
  end

  class IndexBuilderTest < ActiveSupport::TestCase
    class ESMock
      include Elasticsearch::Model

      def self.reset_mapping(options: {})
      end
    end

    class UserMock < ESMock
      document_type :user
      mappings do
        indexes :id
      end
    end

    class TransactableMock < ESMock
      document_type :transactable
      mappings do
        indexes :id
        indexes :transactable_type
      end
    end

    test 'build initial configuration index' do

      factory = Elastic::Factory.new(config: Elastic::Configuration.new(type: :test, instance_id: 1))

      factory.build.body.tap do |body|
        assert_equal body.dig(:settings), index: { number_of_shards: 1 }
        assert_equal body.dig(:aliases), 'test-1--user-transactables-alias' => {}
        assert body.dig(:mappings, :user, :properties)
        assert body.dig(:mappings, :transactable, :properties)
      end

      factory.build(version: 2).body.tap do |body|
        assert_equal body.dig(:settings), index: { number_of_shards: 1 }
        assert_equal body.dig(:aliases), {}
        assert body.dig(:mappings, :user, :properties)
        assert body.dig(:mappings, :transactable, :properties)
      end
    end

    test 'manipulating ES indexes' do
      begin
        # - prepare index-type based on instance and type of required data [mixed, single]
        config = Elastic::Configuration.set(type: :test, instance_id: 1)
        engine = Elastic::Engine.new config: config
        engine.destroy! 'test-*'
        factory = Elastic::Factory.new(config: config)

        # - create index-0 if no index
        unless engine.index_exists? config.index_name
          factory.build(version: 0).tap do |index|
            engine.create_index index
            assert_index_exists index
            assert_theres_only_one_alias index
          end
        end

        # - get current index version
        # - create index-1 [or +1]
        factory.build(version: 1).tap do |index|
          engine.create_index index
          assert_index_exists index
          assert_theres_only_one_alias index
        end

        # find by alias
        engine.find_index(config.index_name).tap do |index|
          assert_equal index.version, 0

          engine.switch_alias from: index, to: factory.build(version: index.version.next)
        end

        engine.find_index(config.index_name).tap do |index|
          assert_equal index.version, 1
        end

        factory.build(version: 2).tap do |index|
          engine.create_index index
          assert_index_exists index
          assert_theres_only_one_alias index
        end

        engine.find_index(config.index_name).tap do |index|
          assert_equal index.version, 1

          engine.switch_alias from: index, to: factory.build(version: index.version.next)
        end

        engine.find_index(config.index_name).tap do |index|
          assert_equal index.version, 2
        end

        engine.destroy! 'test-*'
      end
    end

    def assert_theres_only_one_alias(index)
      assert_equal Elastic::Configuration.current.client.indices.get_alias(name: index.alias_name).count, 1
    end

    def assert_index_exists(index)
      assert Elastic::Configuration.current.client.indices.exists index: index.name
      assert Elastic::Configuration.current.client.indices.exists index: index.alias_name
      assert Elastic::Configuration.current.client.indices.exists_alias name: index.alias_name

      Elastic::Configuration.current.client.indices.get(index: index.name).tap do |es_index|
        assert_equal es_index.dig(index.name, 'mappings', 'user', 'properties').keys, ['id']
        assert_equal es_index.dig(index.name, 'mappings', 'transactable', 'properties').keys, ['id', 'transactable_type']
      end
    end
  end
end
