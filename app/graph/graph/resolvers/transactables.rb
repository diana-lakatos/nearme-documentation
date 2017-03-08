# frozen_string_literal: true
module Graph
  module Resolvers
    class Transactables
      def call(_, arguments, ctx)
        @variables = ctx.query.variables
        decorate(resolve_by(arguments))
      end

      def resolve_by(arguments)
        arguments.keys.reduce(main_scope) do |relation, argument_key|
          public_send("resolve_by_#{argument_key}", relation, arguments[argument_key])
        end
      end

      def decorate(relation)
        relation.map { |transactable| TransactableDrop.new(transactable.decorate) }
      end

      def resolve_by_ids(relation, ids)
        relation.where(id: ids)
      end

      def resolve_by_listing_type_id(listing_type_id)
        relation.for_transactable_type_id(listing_type_id)
      end

      def resolve_by_filters(relation, filters)
        scopes = filters.map(&:downcase)
        scopes.reduce(relation) do |scoped_relation, scope_name|
          scoped_relation.public_send(scope_name)
        end
      end

      def resolve_by_take(relation, number)
        relation.take(number)
      end

      private

      def main_scope
        return ::Transactable.all unless @variables['follower_id']
        ::Transactable.all
          .merge(ActivityFeedSubscription.with_user_id_as_follower(@variables['follower_id'], ::Transactable))
      end
    end
  end
end
