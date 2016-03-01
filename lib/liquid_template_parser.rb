class LiquidTemplateParser

  def initialize(options = {})
    options.reverse_merge!(
      render_method: (::Rails.env.development? || ::Rails.env.test?) ? :render! : :render,
      filters: [LiquidFilters]
      )
    @options = options
  end

  def parse(text, data = {})
    liquid = Liquid::Template.parse(text)
    liquid.send(
      @options[:render_method],
      data.merge(platform_context: PlatformContext.current.decorate).stringify_keys,
      filters: @options[:filters]
      )
  end
end
