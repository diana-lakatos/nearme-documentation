# frozen_string_literal: true
module Graph
  module Resolvers
    module Elastic
      class BaseResolver
        attr_reader :builder, :arguments, :ctx

        delegate :document_types, to: :builder

        def call(parent, arguments, ctx)
          @parent = parent
          @arguments = arguments
          @ctx = ctx

          @builder = ::Elastic::QueryBuilder::Franco.new

          resolve
          builder
        end

        private

        def resolve
          raise 'Implementation missing!'
        end

        def resolve_argument(key)
          return unless block_given?
          return if arguments[key].nil?

          add yield(arguments[key], arguments, key)
        end

        def resolve_arguments
          return unless block_given?

          add yield(arguments)
        end

        def resolve_each_argument
          arguments.each do |argument|
            add yield(argument)
          end
        end

        def add(result)
          builder.add(result)
        end
      end
    end
  end
end
