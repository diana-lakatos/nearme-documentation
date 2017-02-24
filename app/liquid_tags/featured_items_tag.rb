# frozen_string_literal: true
# Usage:
# ```
# {% featured_items target: users, amount: 6 %}
# ```
# or:
# ```
# {% featured_items target: services, amount: 6, type: Boat %}
# ```
# Will render the specified target items which have been marked as featured. In the examples
# "Boat" is the Transactable Type name, amount is the number of featured items to render.
class FeaturedItemsTag < Liquid::Tag
  def initialize(tag_name, arguments, context)
    super

    if arguments =~ /(#{::Liquid::QuotedFragment}+)/
      @arguments = arguments
    else
      raise SyntaxError, 'Syntax Error - Valid syntax: {% featured_items [arguments] %}'
    end
  end

  def render(context)
    @context = context
    @view = @context.registers[:action_view]
    @attributes = {}

    @arguments.scan(Liquid::TagAttributes) do |key, value|
      @attributes[key] = value.gsub(/^'|"/, '').gsub(/'|"$/, '')
    end

    @attributes.symbolize_keys!

    routes = Rails.application.routes.url_helpers

    params = { target: @attributes[:target], amount: @attributes[:amount] }
    params[:type] = @attributes[:type] if @attributes[:type].present?
    route = routes.featured_items_path(params)

    @view.content_tag(:span, '', class: 'featured-items-loader', data: { url: route })
  end
end

class RenderFeaturedItemsTag < Liquid::Tag
  def initialize(tag_name, arguments, context)
    super
  end

  def render(context)
    context.registers[:action_view].render_featured_items
  end
end
