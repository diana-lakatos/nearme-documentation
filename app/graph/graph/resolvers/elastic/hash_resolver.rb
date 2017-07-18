# frozen_string_literal: true
module Graph
  module Resolvers
    module Elastic
      class HashResolver
        def call(object, arguments, _ctx)
          return object unless arguments.keys.present?
          arguments = arguments.to_h
          object.select do |obj|
            arguments.all? { |arg, value| obj[arg] == value }
          end
        end
      end
    end
  end
end
