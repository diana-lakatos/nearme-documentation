# frozen_string_literal: true
module Graph
  module Resolvers
    class Transactable
      def call(_, arguments, _ctx)
        Resolvers::Transactables.decorate(::Transactable.find(arguments[:slug].presence || arguments[:id]))
      end
    end
  end
end
