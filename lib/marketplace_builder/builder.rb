# frozen_string_literal: true
require 'benchmark'

module MarketplaceBuilder
  class Builder
    MODE_REPLACE = 'replace'
    MODE_APPEND = 'append'

    def initialize(instance_id, theme_path, mode = MODE_APPEND)
      @instance = Instance.find(instance_id)
      @instance.set_context!

      MarketplaceBuilder::Logger.info "Marketplace Builder loaded for #{@instance.name}"

      MarketplaceBuilder::Logger.error "Mode #{mode} is not implemented", raise: true if [MODE_REPLACE, MODE_APPEND].include?(mode) == false

      @mode = mode
      @theme_path = theme_path
      @last_run_time = nil

      @creators = []

      add_creator Creators::ReservationTypeCustomAttributesCreator.new
      add_creator Creators::TransactableTypeCustomAttributesCreator.new
      add_creator Creators::InstanceProfileTypeCustomAttributesCreator.new

      add_creator Creators::TransactableTypeFormComponentsCreator.new
      add_creator Creators::InstanceProfileTypeFormComponentsCreator.new
      add_creator Creators::ReservationTypeFormComponentsCreator.new

      add_creator Creators::CategoriesCreator.new
      add_creator Creators::PagesCreator.new
      add_creator Creators::ContentHoldersCreator.new
      add_creator Creators::MailersCreator.new
      add_creator Creators::SMSCreator.new
      add_creator Creators::LiquidViewsCreator.new
      add_creator Creators::TranslationsCreator.new
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
        @creators.each(&:execute!)
        expire_cache
      end

      MarketplaceBuilder::Logger.success "Done in #{@last_run_time.round(2)}s"
    end

    private

    def expire_cache
      MarketplaceBuilder::Logger.info 'Clearing cache...'

      CacheExpiration.send_expire_command 'RebuildInstanceView', instance_id: @instance.id
      CacheExpiration.send_expire_command 'RebuildTranslations', instance_id: @instance.id
      CacheExpiration.send_expire_command 'RebuildCustomAttributes', instance_id: @instance.id
      Rails.cache.clear
    end
  end
end
