# frozen_string_literal: true
module Graph
  Schema = GraphQL::Schema.define do
    query Graph::Types::RootQuery
    mutation Graph::Mutations::RootMutation
    resolve_type lambda { |record, _ctx|
      case record
      when ::Comment
        Graph::Types::ActivityFeed::Comment
      when ::Photo
        Graph::Types::ActivityFeed::Photo
      when ::UserStatusUpdate
        Graph::Types::ActivityFeed::UserStatusUpdate
      when ::Transactable
        Graph::Types::Transactables::Transactable
      when ::Location
        Graph::Types::Location
      when ::Elastic::UserDrop, ::Elastic::SourceTypes::UserSource
        Graph::Types::User
      else
        Graph::Types::ActivityFeed::Generic
      end
    }
  end

  def self.execute(*args)
    response = ::Graph::Schema.execute(*args)
    if response.key?('data') && !response.key?('errors')
      response.fetch('data')
    else
      throw(ArgumentError.new(response['errors'].to_s + response.pretty_inspect))
    end
  end

  def self.execute_query(query_string, variables: {}, context: {})
    execute(
      query_string,
      variables: variables,
      context: {
        current_user_id: context['current_user']&.id,
        liquid_context: context
      }
    )
  end

  def self.execute_stored_query(query_name, variables)
    execute_query(
      Graph::QueryResolver.find_query(query_name),
      variables: variables
    )
  end
end
