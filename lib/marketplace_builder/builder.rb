# frozen_string_literal: true
require 'benchmark'

module MarketplaceBuilder
  MODE_REPLACE = 'replace'
  MODE_APPEND = 'append'

  class Builder
    def initialize(instance_id, theme_path, mode = MarketplaceBuilder::MODE_APPEND, debug_level = MarketplaceBuilder::Loggers::Logger::INFO)
      @instance = Instance.find(instance_id)
      @instance.set_context!

      logger.level = debug_level

      logger.info "Marketplace Builder loaded for #{@instance.name}"

      raise MarketplaceBuilder::Error, "Mode #{mode} is not implemented" if [MarketplaceBuilder::MODE_REPLACE, MarketplaceBuilder::MODE_APPEND].include?(mode) == false

      @mode = mode
      logger.debug "Running in #{@mode.upcase} mode"

      @theme_path = theme_path
      logger.debug "Loading data from #{theme_path}"

      @last_run_time = nil

      @creators = []

      add_creator Creators::MarketplaceCreator.new
      add_creator Creators::TransactableTypesCreator.new
      add_creator Creators::InstanceProfileTypesCreator.new
      add_creator Creators::ReservationTypesCreator.new
      add_creator Creators::TopicsCreator.new

      add_creator Creators::CategoriesCreator.new
      add_creator Creators::PagesCreator.new
      add_creator Creators::ContentHoldersCreator.new
      add_creator Creators::MailersCreator.new
      add_creator Creators::SMSCreator.new
      add_creator Creators::LiquidViewsCreator.new
      add_creator Creators::TranslationsCreator.new
      add_creator Creators::WorkflowAlertsCreator.new
      add_creator Creators::CustomModelTypesCreator.new
      add_creator Creators::GraphQueriesCreator.new
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

    rescue MarketplaceBuilder::Error => error
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
      Loggers::ConsoleLogger.instance
    end
  end
end
