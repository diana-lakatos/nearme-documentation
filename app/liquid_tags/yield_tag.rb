# corresponding class is lib/liquid_content_for which defines
# !{% content_for '<content_for_name>' %}Hello world!{% endcontent_for %}
# functionality, thanks to which you can use this tag to just call
# !{{ yield '<content_for_name>' }}
class YieldTag < Liquid::Tag
  def initialize(tag_name, content_for_symbol, tokens)
    super
    @content_for_symbol = content_for_symbol.strip.gsub(/\A'|'\Z/, '').to_sym
  end

  def render(context)
    context.registers[:action_view].send(:content_for, @content_for_symbol)
  end
end
