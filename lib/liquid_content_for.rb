module Liquid
  class ContentFor < Liquid::Block
    def initialize(tag_name, arguments_string, tokens)
      super

      arguments_list = arguments_string.split(',')

      @content_for_symbol = arguments_list[0].strip.gsub(/\A\s*'|'\s*\Z/, '').to_sym

      @attributes = {}
      arguments_list[1..-1].join(',').scan(Liquid::TagAttributes) do |key, value|
        @attributes[key] = value.gsub(/^'|"/, '').gsub(/'|"$/, '')
      end
      @attributes.symbolize_keys!
    end

    def render(context)
      context.registers[:action_view].send(:content_for, @content_for_symbol, @attributes) { super.html_safe }
    end
  end

  Liquid::Template.register_tag('content_for', ContentFor)
end
