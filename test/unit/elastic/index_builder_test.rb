require 'test_helper_lite'
require 'elasticsearch'
require 'elasticsearch/model'
require 'active_support'
require 'ostruct'
require 'pry'
require './lib/elastic.rb'
require './lib/elastic/index_factory.rb'
require './lib/elastic/index_types.rb'
require './lib/elastic/engine.rb'
require './lib/elastic/index.rb'

class Elastic::IndexNameTest < ActiveSupport::TestCase
  test 'names are correct' do

    factory = Elastic::IndexNameBuilder.new('test', 1234, 'development', 'user-transactables')
    index_name = factory.build(version: 0)

    assert_equal index_name.name, 'test-1234-development-user-transactables-0'
    assert_equal index_name.alias_name, 'test-1234-development-user-transactables'
    assert_equal index_name.name.next, 'test-1234-development-user-transactables-1'

    index_name = factory.build(version: 1)
    assert_equal index_name.name, 'test-1234-development-user-transactables-1'
    assert_equal index_name.alias_name, 'test-1234-development-user-transactables'
    assert_equal index_name.name.next, 'test-1234-development-user-transactables-2'

    factory = Elastic::IndexNameBuilder.new('test', 1234, 'local', 'default')
    index_name = factory.build(version: 0)
    assert_equal index_name.name, 'test-1234-local-default-0'
    assert_equal index_name.alias_name, 'test-1234-local-default'
    assert_equal index_name.name.next, 'test-1234-local-default-1'
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

class Elastic::IndexBuilderTest < ActiveSupport::TestCase
  class ESMock
    include Elasticsearch::Model

    def self.reset_mapping
      __elasticsearch__
        .instance_variable_set '@mapping',
                               Elasticsearch::Model::Indexing::Mappings.new(document_type)

    end

    def self.reload_mappings(custom_mappings = [])
      reset_mapping

      mappings do
        custom_mappings.each do |key|
          indexes key
        end
      end
    end
  end

  class UserMock < ESMock
    document_type :user
  end

  class TransactableMock < ESMock
    document_type :transactable
  end


  test 'build initial configuration index' do
    type = Elastic::IndexTypes::MultipleModel.new(sources: [UserMock, TransactableMock])

    assert_equal type.body.dig(:settings), index: { number_of_shards: 1 }
    assert_equal type.body.dig(:mappings), user: { properties: {} }, transactable: { properties: {} }
    assert_nil type.body.dig(:aliases)

    type = Elastic::IndexTypes::MultipleModel.new(sources: [UserMock, TransactableMock])

    assert_equal type.body.dig(:settings), index: { number_of_shards: 1 }
    assert_equal type.body.dig(:mappings), user: { properties: {} }, transactable: { properties: {} }
  end

  test 'fixtures and injecting mapping configuration into source class' do
    [UserMock, TransactableMock].product([0, 1, 2].shuffle).each do |source, version|
      mapping = Fixtures.mappings[source.document_type][version]

      source.reload_mappings(mapping)
      assert_equal source.mappings.to_hash[source.document_type][:properties].keys, mapping
      assert_includes source.mappings.to_hash[source.document_type][:properties].keys, 'id'
    end
  end

  test 'manipulating ES indexes' do
    begin
      UserMock.reload_mappings(Fixtures.mappings[:user][0])
      TransactableMock.reload_mappings(Fixtures.mappings[:transactable][0])

      engine = Elastic::Engine.new
      engine.destroy! OpenStruct.new(alias_name: 'test-*')

      # - prepare index-type based on instance and type of required data [mixed, single]
      builder = Elastic::IndexNameBuilder.new('test', 1234, 'development', 'user-transactable')
      index_type = Elastic::IndexTypes::MultipleModel.new(sources: [UserMock, TransactableMock])

      # - create index-0 if no index
      unless engine.index_exists? builder.build.alias_name
        Elastic::IndexZero.new(type: index_type, version: 0, builder: builder).tap do |index_zero|
          engine.create_index index_zero
          has_proper_index index_zero
          theres_only_one_alias index_zero
        end
      end

      # - get current index version
      # - create index-1 [or +1]
      Elastic::Index.new(type: index_type, version: 1, builder: builder).tap do |index|
        engine.create_index index
        has_proper_index index
        theres_only_one_alias index
      end

      engine.find_index(builder.build.alias_name).tap do |index|
        assert_equal index.version, 0
      end

      engine.switch_alias from: builder.build(version: 0), to: builder.build(version: 1)

      engine.find_index(builder.build.alias_name).tap do |index|
        assert_equal index.version, 1
      end

      Elastic::Index.new(type: index_type, version: 2, builder: builder).tap do |index|
        engine.create_index index
        has_proper_index index
        theres_only_one_alias index
      end

      engine.switch_alias from: builder.build(version: 0), to: builder.build(version: 1)

      # engine.import index

      # - import data from provided sources into new index
      # - switch alias
      # - cleanup [optional]

    end
  end

  def theres_only_one_alias(index)
    assert_equal Elasticsearch::Model.client.indices.get_alias(name: index.alias_name).count, 1
  end

  def has_proper_index(index)
    assert Elasticsearch::Model.client.indices.exists index: index.name
    assert Elasticsearch::Model.client.indices.exists index: index.alias_name
    assert Elasticsearch::Model.client.indices.exists_alias name: index.alias_name

    Elasticsearch::Model.client.indices.get(index: index.name).tap do |es_index|
      assert_equal es_index.dig(index.name, 'mappings', 'user', 'properties').keys, ['id']
      assert_equal es_index.dig(index.name, 'mappings', 'transactable', 'properties').keys, ['id', 'transactable_type']
    end
  end
end
