# frozen_string_literal: true
# Usage example:
# ```
#   {% will_paginate collection: @users %}
# ```
# or
# ```
#   {% will_paginate collection: @users, renderer: dashboard %}
# ```
#
# Displays the pagination links for a paginated collection. The second example
# uses the 'dashboard' style renderer.
class WillPaginateTag < Liquid::Tag
  include AttributesParserHelper

  def initialize(tag_name, markup, tokens)
    super
    @attributes = create_initial_hash_from_liquid_tag_markup(markup)
    @collection = @attributes.delete('collection')
  end

  def render(context)
    @attributes['renderer'] = pagination_renderer if @attributes['renderer']
    @attributes = normalize_liquid_tag_attributes(@attributes, context)

    @attributes = normalize_liquid_tag_attributes(@attributes, context, %w(html wrapper_mappings))
    context.registers[:action_view].send(:will_paginate, context[@collection], @attributes)
  end

  private

  def pagination_renderer
    case @attributes['renderer']
    when 'dashboard'
      BuySellMarket::WillPaginateDashboardLinkRenderer::LinkRenderer
    else
      raise NotImplementedError, "Valid renderer options are: 'dashboard', but #{@attributes['renderer']} was given. Typo?"
    end
  end
end
