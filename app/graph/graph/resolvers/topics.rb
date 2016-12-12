# frozen_string_literal: true
module Graph
  module Resolvers
    class Topics
      def call(_, arguments, _)
        decorate(resolve_by(arguments))
      end

      def resolve_by(arguments)
        arguments.keys.sort.reduce(::Topic.all) do |relation, argument_key|
          public_send("resolve_by_#{argument_key}", relation, arguments[argument_key])
        end
      end

      def decorate(relation)
        relation.map { |topic| TopicDrop.new(topic) }
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

      def resolve_by_arbitrary_order(relation, order_values)
        relation.order(
          arbitrary_order_clause(order_values)
        )
      end

      private

      def arbitrary_order_clause(values)
        values.map { |value| "name = '#{value}' DESC" }.join(', ')
      end
    end
  end
end
