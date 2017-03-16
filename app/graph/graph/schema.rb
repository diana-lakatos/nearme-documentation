# frozen_string_literal: true
module Graph
  Schema = GraphQL::Schema.define do
    query Types::RootQuery
  end

  def self.execute_query(*args)
    response = ::Graph::Schema.execute(*args)
    response.key?('data') ? response.fetch('data') : throw(ArgumentError.new(response.pretty_inspect))
  end
end
