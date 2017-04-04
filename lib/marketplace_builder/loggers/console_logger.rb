# frozen_string_literal: true
module MarketplaceBuilder
  module Loggers
    class ConsoleLogger < MarketplaceBuilder::Loggers::Logger
      private

      PREFIXES = {
        Logger::DEBUG => '[DEBUG]',
        Logger::INFO => '[DEBUG]',
        Logger::WARN => '[DEBUG]',
        Logger::ERROR => '[DEBUG]',
        Logger::FATAL => '[DEBUG]'
      }.freeze

      def log(message, level)
        print "\n#{decorate_message(message, level)}"

        $stdout.flush
      end

      def decorate_message(message, level)
        "#{PREFIXES[level]} #{message}"
      end
    end
  end
end
