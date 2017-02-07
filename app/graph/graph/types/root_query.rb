# frozen_string_literal: true
module Graph
  module Types
    RootQuery = GraphQL::ObjectType.define do # rubocop:disable Metrics/BlockLength
      name 'RootQuery'
      description 'Root query for schema'

      field :locations do
        type !types[Types::Location]
        resolve -> (_obj, _args, _ctx) { ::Location.first(10) }
      end

      field :location do
        type Types::Location
        argument :id, !types.ID
        resolve -> (_obj, args, _ctx) { LocationDrop.new(::Location.find(args[:id])) }
      end

      field :transactables do
        type !types[Types::Transactable]
        argument :ids, types[types.ID], 'List of ids'
        argument :listing_type_id, types.ID
        argument :filters, types[Types::TransactableFilterEnum]
        argument :take, types.Int

        resolve Resolvers::Transactables.new
      end

      field :users do
        type !types[Types::User]
        argument :filters, types[Types::UserFilterEnum]
        argument :take, types.Int

        resolve Resolvers::Users.new
      end

      field :user do
        type Types::User
        argument :id, types.ID

          resolve -> (_obj, args, _ctx) { UserDrop.new(::User.find(args[:id])) }
      end

      field :topics do
        type !types[Types::Topic]
        argument :filters, types[Types::TopicFilterEnum]
        argument :take, types.Int
        argument :arbitrary_order, types[types.String]

        resolve Resolvers::Topics.new
      end

      field :feed do
        type !Types::Feed
        resolve Resolvers::Feed
      end

      field :searcher do
        type !Types::Search::Searcher
        argument :transactable_type_id, !types.ID
        argument :result_view, !types.String
        argument :search_params, Types::Search::Params
        resolve Resolvers::Searcher.new
      end
    end
  end
end
