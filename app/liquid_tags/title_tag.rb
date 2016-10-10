class TitleTag < Liquid::Tag
  include AttributesParserHelper

  def initialize(tag_name, title, tokens)
    super
    @title = title
  end

  def render(context)
    context.registers[:action_view].send(:title, context[@title])
    nil
  end
end
