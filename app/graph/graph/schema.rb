# frozen_string_literal: true
module Graph
  Schema = GraphQL::Schema.define do
    query Types::RootQuery
    resolve_type lambda { |record, _ctx|
      case record
      when ::Comment
        Types::ActivityFeed::Comment
      when ::Photo
        Types::ActivityFeed::Photo
      when ::UserStatusUpdate
        Types::ActivityFeed::UserStatusUpdate
      when ::Transactable
        Types::Transactables::Transactable
      when ::Location
        Types::Location
      when ::Elastic::UserDrop
        Types::User
      else
        Types::ActivityFeed::Generic
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
