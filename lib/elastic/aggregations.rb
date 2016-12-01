module Elastic
  module Aggregations
    def self.build(**options)
      builder = Elastic::Aggregations::Builder.new
      builder.add_default(name: :filtered_aggregations, filters: options[:filters])
      builder.add(name: :custom_attributes, filters: options[:filters], fields: options[:fields])

      { aggregations: builder.body }
    end
  end
end
