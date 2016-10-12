module Liquid
  class ContentFor < Liquid::Block
    def initialize(tag_name, content_for_symbol, tokens)
      super
      @content_for_symbol = content_for_symbol.strip.gsub(/\A'|'\Z/, '').to_sym
    end

    def render(context)
      context.registers[:action_view].send(:content_for, @content_for_symbol) { super.html_safe }
    end
  end

  Liquid::Template.register_tag('content_for', ContentFor)
end
