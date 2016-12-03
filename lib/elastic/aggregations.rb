module Elastic
  module Aggregations
    def self.build(**options)
      builder = Elastic::Aggregations::Builder.new
      builder.add_default(name: :filtered_aggregations, filters: options[:filters])

      # FIX: remove aggs only for the-volte
      if PlatformContext.current.instance.id == 194
        builder.add(name: :custom_attributes, filters: options[:filters], fields: options[:fields])
      end

      { aggregations: builder.body }
    end
  end
end
