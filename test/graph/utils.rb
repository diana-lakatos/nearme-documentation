module ES
  def self.index_name
    'test-1--user-transactables-alias'
  end

  def self.search(query:, type: 'transactable')
    client.search(type: type, q: query, body: { _source: ['name'] }, index: index_name)
  end

  def self.client
    Client.new.instance
  end

  def self.around(instance_name:)
    Setup.new(instance_name: instance_name).up

    graph = GraphExplorer.new(instance_name: instance_name)
    yield(graph)
    Setup.new(instance_name: instance_name).down
  end

  class Client
    def instance
      @client ||= Elasticsearch::Client.new log: ENV.key?('DEBUG_ES')
    end
  end

  class Setup
    attr_reader :client

    def initialize(index: ES.index_name, instance_name:, client: Client.new.instance)
      @index = index
      @instance_name = instance_name
      @client = client
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
      JSON.parse File.open("./test/fixtures/#{@instance_name}/mapping.json", 'r').read
    end

    def bulk
      items.each_with_object([]) do |item, memo|
        settings = { _index: @index, _type: item['_type'], _id: item['_id'] }
        settings['_parent'] = item['_parent'] if item['_parent']

        memo << { index: settings }
        memo << item['_source']
      end
    end

    def search(type:, q:, body: {})
      client.search index: @index, q: q, body: body, type: type
    end

    def items
      JSON.parse(File.open("./test/fixtures/#{@instance_name}/items.json").read)
    end
  end
end

class GraphExplorer
  RootQuery = GraphQL::ObjectType.define do
    name 'Root'
    description 'Test root query'

    fields Graph::FieldCombiner.combine([Graph::Types::Queries::Listings])
  end

  Schema = GraphQL::Schema.define do
    query GraphExplorer::RootQuery
    resolve_type ->(_, _, _) { Graph::Types::User }
  end

  def initialize(instance_name:)
    @instance_name = instance_name
  end

  def execute(name, variables = {})
    puts variables if ENV['DEBUG_ES']

    GraphExplorer::Schema.execute(query(name), variables: variables).tap do |response|
      raise response['errors'].map { |e| e['message'] }.inspect if response['errors']
    end
  end

  private

  def query(name)
    File.read(format './test/fixtures/%s/%s.graphql', @instance_name, name)
  end
end
