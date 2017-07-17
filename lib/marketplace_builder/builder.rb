# frozen_string_literal: true
require 'benchmark'

module MarketplaceBuilder
  MODE_REPLACE = 'replace'
  MODE_APPEND = 'append'

  class Builder
    def initialize(instance_id, theme_path, creators = Loader::AVAILABLE_CREATORS_LIST, options = {})
      default_options = {
        mode: MarketplaceBuilder::MODE_APPEND,
        debug_level: MarketplaceBuilder::Loggers::Logger::INFO
      }

      options = options.reverse_merge(default_options)

      @instance = Instance.find(instance_id)
      @instance.set_context!

      logger.level = options[:debug_level]

      logger.info "Marketplace Builder loaded for #{@instance.name}"

      raise MarketplaceBuilder::MarketplaceBuilderError, "Mode #{options[:mode]} is not implemented" if [MarketplaceBuilder::MODE_REPLACE, MarketplaceBuilder::MODE_APPEND].include?(options[:mode]) == false

      @mode = options[:mode]
      logger.debug "Running in #{@mode.upcase} mode"

      @theme_path = theme_path
      logger.debug "Loading data from #{theme_path}"

      @last_run_time = nil

      @creators = []

      creators.each do |klass|
        add_creator klass.new
      end
    end

    def add_creator(*creators)
      creators.each do |creator|
        creator.set_instance(@instance)
        creator.set_theme_path(@theme_path)
        creator.set_mode(@mode)
        @creators << creator
      end
    end

    def execute!
      @last_run_time = Benchmark.realtime do
        @creators.each do |creator|
          creator.cleanup! if @mode == MarketplaceBuilder::MODE_REPLACE
          creator.execute!
        end
        expire_cache
      end

      logger.info "Finished in #{@last_run_time.round(2)}s"

    rescue MarketplaceBuilder::MarketplaceBuilderError => error
      logger.fatal error
    end

    private

    def expire_cache
      logger.info 'Clearing cache'

      CacheExpiration.send_expire_command 'RebuildInstanceView', instance_id: @instance.id
      logger.debug 'Clearing liquid views cache'

      CacheExpiration.send_expire_command 'RebuildTranslations', instance_id: @instance.id
      logger.debug 'Clearing translations cache'

      CacheExpiration.send_expire_command 'RebuildCustomAttributes', instance_id: @instance.id
      logger.debug 'Clearing custom attributes cache'

      Rails.cache.clear
      logger.debug 'Clearing application cache'
    end

    def logger
      @logger ||= if Rails.env.test?
                    Logger.new('/dev/null')
                  else
                    Loggers::ConsoleLogger.instance
                  end
    end
  end
end
