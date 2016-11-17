# frozen_string_literal: true
# Usage:
# ```
# {% inject_content_holder name_of_holder %}
# ```
# Will render the content holder (defined in the admin section of the marketplace) with the specified name;
# the content holder must not specify inject pages or the 'meta' or 'head bottom' positions in admin.
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
