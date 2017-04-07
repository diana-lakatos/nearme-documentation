# frozen_string_literal: true
module Graph
  Schema = GraphQL::Schema.define do
    query Types::RootQuery
     resolve_type ->(record, ctx) {
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
    response.key?('data') ? response.fetch('data') : throw(ArgumentError.new(response.pretty_inspect))
  end

  def self.execute(query_name, variables)
    execute_query(
      Graph::QueryResolver.find_query(query_name),
      variables: variables
    )
  end
end
