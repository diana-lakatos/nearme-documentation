class LiquidTemplateParser
  LIQUID_ERROR = 'Liquid Error'.freeze

  def initialize(
    filters: [LiquidFilters],
    registers: {},
    logger: MarketplaceLogger,
    default_data: { platform_context: PlatformContext.current.decorate },
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
    liquid.send(
      render_method,
      data.merge(@default_data).stringify_keys,
      filters: @filters, registers: @registers
    )
  rescue Liquid::SyntaxError => e
    log_error(e.to_s, source)
    reraise
  ensure
    log_error(e.to_s, source) if liquid && liquid.errors.any?
  end

  private

  def render_method
    @raise_mode ? :render! : :render
  end

  def reraise
    @raise_mode ? raise : LIQUID_ERROR
  end

  def log_error(error_message, stacktrace)
    @logger.error(LIQUID_ERROR, error_message, raise: false, stacktrace: stacktrace)
  end
end
