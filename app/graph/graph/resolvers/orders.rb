# frozen_string_literal: true
module Graph
  module Resolvers
    class Orders
      def call(parent_object, arguments, _ctx)
        resolve_by(arguments, parent_object&.orders)
      end

      def resolve_by(arguments, initial_relation)
        initial_relation ||= ::Order.all
        arguments.keys.reduce(initial_relation) do |relation, argument_key|
          public_send("resolve_by_#{argument_key}", relation, arguments[argument_key])
        end
      end

      def resolve_by_reviewable(relation, reviewable)
        return relation unless reviewable
        relation.reviewable
      end

      def resolve_by_user_id(relation, id)
        relation.where(user_id: id)
      end

      def resolve_by_archived(relation, archived)
        if archived
          relation.where.not(archived_at: nil)
        elsif archived == false
          relation.where(archived_at: nil)
        else
          relation
        end
      end

      def resolve_by_creator_id(relation, id)
        relation.where(creator_id: id)
      end

      def resolve_by_state(relation, state)
        relation.where(state: state)
      end

      def resolve_by_states(relation, states)
        relation.with_state(states)
      end
    end
  end
end
