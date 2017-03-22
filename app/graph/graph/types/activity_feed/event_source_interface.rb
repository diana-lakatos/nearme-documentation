module Graph
  module Types
    module ActivityFeed
      EventSourceInterface = GraphQL::InterfaceType.define do
        name 'EventSource'
        field :url, types.String do
          resolve Resolvers::ResourceUrl.new
        end
      end
    end
  end
end
