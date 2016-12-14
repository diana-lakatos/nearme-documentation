require 'singleton'

# frozen_string_literal: true
module MarketplaceBuilder
  module Loggers
    class Logger
      attr_reader :level

      include Singleton

      DEBUG = 1
      INFO = 2
      WARN = 3
      ERROR = 4
      FATAL = 5

      def initialize(level = Logger::INFO)
        self.level = level
      end

      def debug(message)
        log_after_level_check(message, Logger::DEBUG)
      end

      def info(message)
        log_after_level_check(message, Logger::INFO)
      end

      def warn(message)
        log_after_level_check(message, Logger::WARN)
      end

      def error(message)
        log_after_level_check(message, Logger::ERROR)
      end

      def fatal(message)
        log_after_level_check(message, Logger::FATAL)
      end

      def level=(level)
        raise ArgumentError, "Invalid logger level #{level}" unless is_valid_level?(level)
        @level = level
      end

      protected

      def log(_message, _level)
        raise NotImplementedError
      end

      def log_after_level_check(message, level)
        log(message, level) if level >= @level
      end

      def is_valid_level?(level)
        (level >= Logger::DEBUG && level <= Logger::FATAL)
      end
    end
  end
end
