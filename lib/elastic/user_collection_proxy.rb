# frozen_string_literal: true
# we need this wrapper because of elasticsearch-model results immutable implementation
module Elastic
  class UserCollectionProxy < SimpleDelegator
    delegate :each, :map, to: :results

    def results
      __getobj__.results.map { |u| u.extend(Liquidable) }
    end

    module Liquidable
      def to_liquid
        Elastic::UserDrop.new(_source)
      end
    end
  end
end
