# frozen_string_literal: true

module MarketplaceBuilder
  module Creators
    class MarketplaceCreator < DataCreator
      def whitelisted_attributes
        %w(name is_community)
      end

      def execute!
        data = get_data
        return if data.empty?

        MarketplaceBuilder::Logger.log 'Updating instance attributes'

        data.keys.each do |key|
          unless whitelisted_attributes.include? key
            MarketplaceBuilder::Logger.error "#{key} is not an allowed attribute", raise: true
          end

          MarketplaceBuilder::Logger.log "\t#{key}: #{data[key]}"
          @instance.update_attribute(key, data[key])
        end
      end

      private

      def source
        'instance_attributes.yml'
      end
    end
  end
end
