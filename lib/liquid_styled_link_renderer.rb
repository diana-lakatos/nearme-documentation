class LiquidStyledLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper

  def tag(name, value, attributes = {})
    string_attributes = attributes.inject('') do |attrs, pair|
      unless pair.last.nil?
        attrs << %( #{pair.first}="#{CGI.escapeHTML(pair.last.to_s)}")
      end
      attrs
    end
    "<#{name}#{string_attributes}>#{value}</#{name}>"
  end

  def link(text, target, attributes = {})
    if target.is_a? Fixnum
      attributes[:rel] = rel_value(target)
      target = url(target)
    end
    attributes[:href] = target
    attributes[:'data-remote'] = true if @options[:remote].present?
    tag(:a, text, attributes)
  end

  def page_number(page)
    unless page == current_page
      tag(:li, link(page, page, rel: rel_value(page), class: 'page-link'))
    else
      tag(:li, link(page, page, rel: rel_value(page), class: 'page-link active'))
    end
  end

  def previous_or_next_page(page, text, classname)
    if page
      tag(:li, link(text, page), class: classname)
    else
      tag(:li, "<a>#{text}</a>", class: classname + ' disabled')
    end
  end

  def previous_page
    num = @collection.current_page > 1 && @collection.current_page - 1
    previous_or_next_page(num, "<img src='#{ActionController::Base.helpers.asset_path('themes/buy_sell/pagination-left.png')}'/>", 'previous_page')
  end

  def next_page
    num = @collection.current_page < total_pages && @collection.current_page + 1
    previous_or_next_page(num, "<img src='#{ActionController::Base.helpers.asset_path('themes/buy_sell/pagination-right.png')}'/>", 'next_page')
  end

  def html_container(html)
    tag(:ul, html, container_attributes)
  end

  alias_method :to_html_original, :to_html

  def url(page)
    @base_url_params ||= begin
      url_params = base_url_params
      merge_optional_params(url_params)
      url_params
    end

    url_params = @base_url_params.dup
    add_current_page_param(url_params, page)
    @options[:controller].url_for(url_params)
  end

  def base_url_params
    url_params = default_url_params
    # page links should preserve GET parameters
    symbolized_update(url_params, @options[:controller].params) if @options[:controller].request.get?
    url_params
  end

  def to_html
    return "<p><strong style=\"color:red;\">(Will Paginate Liquidized) Error:</strong> you must pass a controller in Liquid render call; <br/>
            e.g. Liquid::Template.parse(\"{{ movies | will_paginate }}\").render({'movies' => @movies}, :registers => {:controller => @controller})</p>" unless @options[:controller]

    to_html_original
  end

  def merge_optional_params(url_params)
    symbolized_update(url_params, @options[:controller].params) if @options[:controller].params
    url_params
  end

  def add_current_page_param(url_params, page)
    url_params[param_name.to_sym] = page
  end

  def merge_get_params(url_params)
    if @template.respond_to?(:request) && @template.request && @template.request.get?
      symbolized_update(url_params, @template.params)
    end
    url_params
  end

  def default_url_params
    {}
  end
end
