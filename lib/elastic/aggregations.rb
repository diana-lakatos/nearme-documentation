# frozen_string_literal: true
module Elastic
  module Aggregations
    def self.build(**options)
      builder = Elastic::Aggregations::Builder.new

      builder.add_default(name: :filtered_aggregations, filters: options[:filters])
      builder.add(name: :properties, filters: options[:filters], fields: options[:fields])
      builder.add_global(name: 'global', fields: options[:fields])

      { aggregations: builder.body }
    end
  end
end
