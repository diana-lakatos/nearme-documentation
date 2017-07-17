# frozen_string_literal: true
module Graph
  module Resolvers
    module AR
      class BaseResolver
        attr_reader :scope, :arguments, :ctx
        def initialize(collection = nil)
          @collection = collection
        end

        def call(parent, arguments, ctx)
          @parent = parent
          @ctx = ctx
          @arguments = arguments
          @scope = collection

          resolve
          decorate_collection
        end
        #
        #   resolve_argument :since do |since_date, scope|
        #     scope.where("#{table_name}.created_at > ?", Time.zone.at(since_date.to_i))
        #   end
        #

        def resolve
          raise 'Implementation missing!'
        end

        private

        def decorate_collection
          @scope.map { |item| decorate(item) }
        end

        def resolve_arguments
          return unless block_given?

          @scope = yield(arguments)
        end

        def resolve_argument(argument)
          return unless arguments.key? argument

          @scope = yield(arguments[argument], scope)
        end

        def decorate(object)
          object
        end

        def collection
          @collection || main_scope
        end

        def main_scope
          raise NotImplementedError
        end

        def table_name
          collection.table.name
        end
      end
    end
  end
end
