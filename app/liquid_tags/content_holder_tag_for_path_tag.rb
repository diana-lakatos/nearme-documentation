class ContentHolderTagForPathTag < Liquid::Tag
  include ContentHoldersHelper

  def initialize(tag_name, holder_name, tokens)
    super

    @holder_name = holder_name.strip.presence
  end

  def render(context)
    controller = context.registers[:action_view].controller_path
    action = context.registers[:action_view].action_name

    # This can be nil if the current page is not in that hash
    group_name = ContentHolder::INJECT_PAGES[[controller, action].join('#')]
    contents = get_content_holders_for_path(group_name).map(&:with_content_for).join
    @template = Liquid::Template.parse(contents)
    @template.render(context)
  end

end

Liquid::Template.register_tag('inject_content_holder_for_path', ContentHolderTagForPathTag)
