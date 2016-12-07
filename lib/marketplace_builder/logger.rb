# frozen_string_literal: true
module MarketplaceBuilder
  class Logger
    def self.defaults
      {
        new_line: true,
        flush: false,
        raise: false
      }
    end

    def self.log(message, options = {})
      options = defaults.merge(options)

      message = "\n#{message}" if options[:new_line]

      print message

      $stdout.flush if options[:flush]

      raise MarketplaceBuilder::Error, message if options[:raise]
    end

    def self.info(message, options = {})
      log "\e[33m#{message}\e[0m", options
    end

    def self.error(message, options = {})
      log "\e[31m#{message}\e[0m", options
    end

    def self.success(message, options = {})
      log "\e[32m#{message}\e[0m", options
    end
  end
end
