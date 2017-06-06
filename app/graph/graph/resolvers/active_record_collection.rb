# frozen_string_literal: true
module Graph
  module Resolvers
    class ActiveRecordCollection
      def initialize(collection = nil)
        @collection = collection
      end

      def call(_, arguments, _ctx)
        @arguments = arguments
        resolve_by(arguments)
      end

      def resolve_by(arguments)
        arguments.keys.reduce(collection) do |relation, argument_key|
          public_send("resolve_by_#{argument_key}", relation, arguments[argument_key])
        end
      end

      def resolve_by_since(relation, since_date)
        relation.where('created_at > ?', Time.zone.at(since_date.to_i))
      end

      def resolve_by_paginate(relation, params)
        relation.paginate(page: params[:page], per_page: params[:per_page])
      end

      private

      def collection
        @collection || main_scope
      end

      def main_scope
        raise NotImplementedError
      end
    end
  end
end
