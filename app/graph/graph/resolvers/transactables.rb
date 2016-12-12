# frozen_string_literal: true
module Graph
  module Resolvers
    class Transactables
      def call(_, arguments, _)
        decorate(resolve_by(arguments))
      end

      def resolve_by(arguments)
        arguments.keys.reduce(::Transactable.all) do |relation, argument_key|
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
    end
  end
end
