# frozen_string_literal: true
module Graph
  module Resolvers
    class Orders
      def call(_, arguments, ctx)
        @variables = ctx.query.variables
        resolve_by(arguments)
      end

      def resolve_by(arguments)
        arguments.keys.reduce(::Order.all) do |relation, argument_key|
          public_send("resolve_by_#{argument_key}", relation, arguments[argument_key])
        end
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
    end
  end
end
