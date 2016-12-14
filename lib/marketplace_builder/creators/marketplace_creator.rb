# frozen_string_literal: true

module MarketplaceBuilder
  module Creators
    class MarketplaceCreator < DataCreator
      def execute!
        data = get_data
        return if data.empty?

        logger.info 'Updating instance attributes'

        data.keys.each do |key|
          return logger.error "#{key} is not an allowed attribute" unless @instance.respond_to? key

          logger.debug "Setting instance attribute #{key}: #{data[key]}"
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
