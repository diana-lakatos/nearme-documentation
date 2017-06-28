# frozen_string_literal: true
module Liquify
  class LiquidTemplateParser
    LIQUID_ERROR = 'Liquid Error'
    RENDER_WITH_RAISE = :render!
    RENDER_SAFE = :render

    def initialize(
      filters: [Liquid::LiquidFilters],
      registers: {},
      logger: MarketplaceLogger,
      default_data: { platform_context: PlatformContext.current&.decorate },
      raise_mode: ::Rails.env.development?
    )
      @filters = filters
      @registers = registers
      @logger = logger
      @default_data = default_data
      @raise_mode = raise_mode
    end

    def parse(source, data = {})
      liquid = Liquid::Template.parse(source)
      render_liquid(liquid, data)
    rescue Liquid::SyntaxError => e
      log_error(e.to_s, source)
      reraise
    ensure
      log_runtime_error(liquid, source, data)
    end

    private

    def render_liquid(liquid, data, render = render_method)
      liquid.send(
        render,
        data.merge(@default_data).stringify_keys,
        filters: @filters, registers: @registers
      )
    end

    def log_runtime_error(liquid, source, data)
      return if !liquid || liquid.errors.empty?

      render_liquid(liquid, data, RENDER_WITH_RAISE)
    rescue StandardError => e
      log_error(e.message, source)
    end

    def render_method
      @raise_mode ? RENDER_WITH_RAISE : RENDER_SAFE
    end

    def reraise
      @raise_mode ? raise : LIQUID_ERROR
    end

    def log_error(error_message, stacktrace)
      @logger.error(LIQUID_ERROR, error_message, raise: false, stacktrace: stacktrace)
    end
  end
end
