class LiquidSelectTag < Liquid::Tag
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper

  def initialize(tag_name, param=nil, tokens)
    super; @param = param
  end

  def render(context)
    select_tag(name, collection(context: context), class: classes.join(" "))
  end

  def name
    raise NameNotDefinedError.new("#name wasn't defined for this select")
  end

  def collection
    raise CollectionNotDefinedError.new("#collection wasn't defined for this select")
  end

  def classes
    %w()
  end

  class NameNotDefinedError < StandardError; end
  class CollectionNotDefinedError < StandardError; end
end
