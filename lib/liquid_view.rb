# frozen_string_literal: true
# LiquidView is a action view extension class. You can register it with rails
# and use liquid as an template system for .liquid files
#
# Example
#
#   ActionView::Base::register_template_handler :liquid, LiquidView
class LiquidView
  LIQUID_ERROR = 'Liquid Error'
  PROTECTED_ASSIGNS = %w( template_root response _session template_class action_name request_origin session template
                          _response url _request _cookies variables_added _flash params _headers request cookies
                          ignore_missing_templates flash _params logger before_filter_chain_aborted headers ).freeze
  PROTECTED_INSTANCE_VARIABLES = %i( @_request @controller @_first_render @_memoized__pick_template @view_paths
                                     @helpers @assigns_added @template @_render_stack @template_format @assigns
                                     @_routes @_config @view_renderer @language_service @marked_for_same_origin_verification
                                     @language_router @set_paper_trail_whodunnit_called @transactable_type @_assigns
                                     @_controller @view_flow @output_buffer @virtual_path @show_title @haml_buffer
                                     @platform_context_view @_main_app).freeze

  Liquid::Template.register_tag('inject_content_holder_for_path', ContentHolderTagForPathTag)
  Liquid::Template.register_tag('inject_content_holder', ContentHolderTag)
  Liquid::Template.register_tag('languages_select', LanguagesSelectTag)
  Liquid::Template.register_tag('transactable_type_select', TransactableTypeSelectTag)
  Liquid::Template.register_tag('featured_items', FeaturedItemsTag)
  Liquid::Template.register_tag('render_featured_items', RenderFeaturedItemsTag)
  Liquid::Template.register_tag('yield', YieldTag)
  Liquid::Template.register_tag('form_tag', FormTagTag)
  Liquid::Template.register_tag('form_for', FormForTag)
  Liquid::Template.register_tag('input', InputTag)
  Liquid::Template.register_tag('submit', SubmitTag)
  Liquid::Template.register_tag('fields_for', FieldsForTag)
  Liquid::Template.register_tag('dropdown_menu', DropdownMenuBlock)
  Liquid::Template.register_tag('will_paginate', WillPaginateTag)
  Liquid::Template.register_tag('title', TitleTag)

  def self.call(template)
    "LiquidView.new(self).render(#{template.source.inspect}, local_assigns)"
  end

  def initialize(view)
    @view = view
  end

  def render(source, local_assigns = {})
    @view.controller.headers['Content-Type'] ||= 'text/html; charset=utf-8' if @view.controller.respond_to?(:headers)

    assigns = @view.assigns.reject { |k, _v| PROTECTED_ASSIGNS.include?(k) }

    assigns['platform_context'] = PlatformContext.current.decorate
    assigns['current_year'] = Date.current.year
    params = @view.try(:controller).try(:params) || {}
    assigns['params'] = params.except(*Rails.application.config.filter_parameters)
    assigns['current_url'] = @view.try(:controller).try(:request).try(:original_url)
    assigns['current_path'] = @view.try(:controller).try(:request).try(:path)
    assigns['request_referer'] = @view.try(:controller).try(:request).try(:referer)
    assigns['current_full_path'] = @view.try(:controller).try(:request).try(:original_fullpath)
    assigns['current_user'] = @view.try(:controller).try(:current_user)
    assigns['build_new_user'] = User.new.to_liquid
    assigns['flash'] = @view.try(:flash).try(:to_hash) if ApplicationController === @view.try(:controller)
    assigns['form_authenticity_token'] = @view.try(:controller).try(:form_authenticity_token)

    # this will need to be cached for performance reason
    if PlatformContext.current.custom_theme.present?
      assigns['asset_url'] = PlatformContext.current.custom_theme.custom_theme_assets.each_with_object({}) do |custom_theme_asset, hash|
        hash[custom_theme_asset.name] = custom_theme_asset.file.url
        hash
      end
    end

    if content_for_layout = @view.instance_variable_get('@content_for_layout')
      assigns['content_for_layout'] = content_for_layout
    elsif @view.content_for?(:layout)
      assigns['content_for_layout'] = @view.content_for(:layout)
    end
    assigns.merge!(local_assigns.stringify_keys)

    controller = @view.controller

    tags = tags_from_controller(controller)
    register_tags(tags)

    begin
      liquid = Liquid::Template.parse(source)
    rescue => e
      MarketplaceLogger.error(LIQUID_ERROR, e.to_s, raise: false, stacktrace: e.backtrace)
      raise
    end

    filters = filters_from_controller(controller) + [LiquidFilters]

    render_method = ::Rails.env.production? ? :render : :render!
    liquid.send(render_method, assigns, filters: filters, registers: { action_view: @view, controller: @view.controller }).html_safe
  end

  def compilable?
    false
  end

  def filters_from_controller(controller)
    filters = if controller.respond_to?(:liquid_filters, true)
                controller.send(:liquid_filters)
              elsif controller.respond_to?(:master_helper_module)
                [controller.master_helper_module]
              else
                [controller._helpers]
              end

    filters
  end

  def register_tags(tags)
    tags.keys.each do |key|
      Liquid::Template.register_tag(key, tags.fetch(key))
    end
  end

  def tags_from_controller(controller)
    tags = if controller.respond_to?(:liquid_tags, true)
             controller.send(:liquid_tags)
           else
             {}
           end

    tags
  end
end
