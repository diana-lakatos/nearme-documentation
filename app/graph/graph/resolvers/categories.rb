# frozen_string_literal: true
module Graph
  module Resolvers
    class Categories
      attr_reader :scope, :arguments, :ctx
      def call(_, arguments, ctx)
        @ctx = ctx
        @arguments = arguments

        @scope = ::Category.all

        resolve
        decorate_collection
      end

      def resolve
        resolve_argument :name_of_root do |value, scope|
          scope.where('categories.permalink like :permalink', permalink: "#{value.parameterize}/%")
        end

        resolve_arguments do |scope|
          scope.order('position', 'permalink')
        end
      end

      private

      def decorate_collection
        @scope.map { |item| decorate(item) }
      end

      def resolve_arguments
        @scope = yield(scope)
      end

      def resolve_argument(argument)
        return unless arguments.key? argument

        @scope = yield(arguments[argument], scope)
      end

      def decorate(category)
        Hashie::Mash.new ::ElasticIndexer::CategorySerializer.new(category, except: [:name_of_root]).as_json
      end
    end
  end
end
