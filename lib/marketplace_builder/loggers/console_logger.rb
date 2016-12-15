require 'colorize'

# frozen_string_literal: true
module MarketplaceBuilder
  module Loggers
    class ConsoleLogger < MarketplaceBuilder::Loggers::Logger
      private

      def log(message, level)
        case level
        when Logger::DEBUG
          message = "[DEBUG] #{message}"
        when Logger::INFO
          message = "[INFO] #{message}".white
        when Logger::WARN
          message = "[WARN] #{message}".yellow
        when Logger::ERROR
          message = "[ERROR] #{message}".red
        when Logger::FATAL
          message = "[FATAL] #{message}".white.on_red
        end

        print "\n#{message}"

        $stdout.flush
      end
    end
  end
end
