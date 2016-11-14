# Usage: 
# ```
# {% inject_content_holder_for_path %}
# ```
# Will render all content holders (defined in the admin section of the marketplace) at their specified location,
# and for the current path. Usually placed in the layout(s).
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
    group_name = ContentHoldersHelper::INJECT_PAGES[[controller, action].join('#')]
    contents = get_content_holders_for_path(group_name).map(&:with_content_for).join
    @template = Liquid::Template.parse(contents)
    @template.render(context)
  end
end
