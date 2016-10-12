module BuySellMarket::WillPaginateDashboardLinkRenderer
  class LinkRenderer < WillPaginate::ViewHelpers::LinkRenderer
    protected

    def page_number(page)
      unless page == current_page
        tag(:li, link(page, page, rel: rel_value(page)))
      else
        tag(:li, link(page, page, rel: rel_value(page)), class: 'active')
      end
    end

    def previous_or_next_page(page, text, classname, label)
      if page
        tag(:li, link(text, page, aria: { label: label }), class: classname)
      end
    end

    def previous_page
      num = @collection.current_page > 1 && @collection.current_page - 1
      previous_or_next_page(num, '<span aria-hidden="true">&lsaquo;</span>', 'prev', I18n.t('pagination.previous'))
    end

    def next_page
      num = @collection.current_page < total_pages && @collection.current_page + 1
      previous_or_next_page(num, '<span aria-hidden="true">&rsaquo;</span>', 'next', I18n.t('pagination.next'))
    end

    def gap
      text = @template.will_paginate_translate(:page_gap) { '&hellip;' }
      %(<li class="gap"><span>#{text}</span></li>)
    end

    def html_container(html)
      tag(:nav, tag(:ul, html, class: 'pagination'), container_attributes)
    end

    def default_url_params
      {}
    end

    def url(page)
      @base_url_params ||= begin
        url_params = merge_get_params(default_url_params)
        url_params[:only_path] = true
        merge_optional_params(url_params)
      end

      url_params = @base_url_params.dup
      add_current_page_param(url_params, page)

      @template.url_for(url_params)
    end

    def merge_get_params(url_params)
      if @template.respond_to?(:request) && @template.request && @template.request.get?
        symbolized_update(url_params, @template.params)
      end
      url_params
    end

    def merge_optional_params(url_params)
      symbolized_update(url_params, @options[:params]) if @options[:params]
      url_params
    end

    def add_current_page_param(url_params, page)
      unless param_name.index(/[^\w-]/)
        url_params[param_name.to_sym] = page
      else
        page_param = parse_query_parameters("#{param_name}=#{page}")
        symbolized_update(url_params, page_param)
      end
    end

    private

    def parse_query_parameters(params)
      Rack::Utils.parse_nested_query(params)
    end
  end
end
