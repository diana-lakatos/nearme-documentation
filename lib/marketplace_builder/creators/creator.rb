# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class Creator
      def initialize
      end

      def set_theme_path(theme_path)
        @theme_path = theme_path
      end

      def set_instance(instance)
        @instance = instance
      end

      def set_mode(mode)
        @mode = mode
      end

      def execute!
        raise NotImplementedError
      end

      def cleanup!
        logger.warn "cleanup! method not implemented for #{self.class}"
      end

      def logger
        Loggers::ConsoleLogger.instance
      end
    end
  end
end
