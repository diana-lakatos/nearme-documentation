# frozen_string_literal: true
module Graph
  Schema = GraphQL::Schema.define do
    query Types::RootQuery
    resolve_type lambda { |record, _ctx|
      case record
      when Comment
        Types::ActivityFeed::Comment
      when Photo
        Types::ActivityFeed::Photo
      when UserStatusUpdate
        Types::ActivityFeed::UserStatusUpdate
      else
        Types::ActivityFeed::Generic
      end
    }
  end

  def self.execute_query(*args)
    response = ::Graph::Schema.execute(*args)
    if response.key?('data') && !response.key?('errors')
      response.fetch('data')
    else
      throw(ArgumentError.new(response['errors'].to_s + response.pretty_inspect))
    end
  end

  def self.execute(query_name, variables)
    execute_query(
      Graph::QueryResolver.find_query(query_name),
      variables: variables
    )
  end
end
