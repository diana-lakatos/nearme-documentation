class ContentHolderTag < Liquid::Tag
  include ContentHoldersHelper

  def initialize(tag_name, holder_name, tokens)
    super

    @holder_name = holder_name.strip
  end

  def render(context)
    @template = Liquid::Template.parse(get_content_holder(@holder_name))
    @template.render(context)
  end
end
