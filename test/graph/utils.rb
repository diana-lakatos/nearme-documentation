module ES
  def self.query(query:, type: 'transactable')
    client.search(type: type, q: query, body: { _source: ['name'] })
  end

  def self.client
    Setup.new(index: 'test-1--user-transactables-alias')
  end

  def self.around
    Setup.up
    yield
    Setup.down
  end

  class Setup
    def self.up
      new(index: 'test-1--user-transactables-alias').up
    end

    def self.down
      new(index: 'test-1--user-transactables-alias').down
    end

    def initialize(index:)
      @index = index
    end

    def down
      client.indices.delete index: @index
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      puts 'no index?'
    end

    def up(retries = 1)
      client.indices.create index: @index, body: mappings
      client.bulk body: bulk
      client.indices.refresh
    rescue Elasticsearch::Transport::Transport::Errors::BadRequest
      down
      retry unless (retries -= 1).negative?
      raise $!
    end

    def mappings
      JSON.parse File.open('./test/fixtures/spacer/mapping.json', 'r').read
    end

    def bulk
      items.each_with_object([]) do |item, memo|
        settings = { _index: @index, _type: item['_type'], _id: item['_id'] }
        settings['_parent'] = item['_parent'] if item['_parent']

        memo << { index: settings }
        memo << item['_source']
      end
    end

    def index(args)
      client.index args
    end

    def search(type: , q:, body: {})
      client.search index: @index, q: q, body: body, type: type
    end

    def client
      Elasticsearch::Client.new
    end

    def items
      JSON.parse(File.open('./test/fixtures/spacer/items.json').read)
    end
  end
end

module G
  RootQuery = GraphQL::ObjectType.define do
    name 'Root'
    description 'Test root query'

    fields Graph::FieldCombiner.combine([Graph::Types::Queries::Listings])
  end

  Schema = GraphQL::Schema.define do
    query G::RootQuery
    resolve_type lambda { |record, _ctx|
        Graph::Types::User
    }
  end

  def self.execute(query, variables = {})
    puts variables if ENV['DEBUG_ES']
    G::Schema.execute(query, variables: variables).tap do |response|
      raise response['errors'].map { |e| e['message'] }.inspect if response['errors']
    end
  end
end

module Queries
  def self.listings
    @file ||= File.read('./test/fixtures/spacer/listings.graphql')
  end
end
