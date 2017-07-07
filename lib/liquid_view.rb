# frozen_string_literal: true
# LiquidView is a action view extension class. You can register it with rails
# and use liquid as an template system for .liquid files
#
# Example
#
#   ActionView::Base::register_template_handler :liquid, LiquidView
class LiquidView
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
  Liquid::Template.register_tag('label', LabelTag)
  Liquid::Template.register_tag('input_field', InputFieldTag)
  Liquid::Template.register_tag('input_field_error', InputFieldErrorTag)
  Liquid::Template.register_tag('submit', SubmitTag)
  Liquid::Template.register_tag('fields_for', FieldsForTag)
  Liquid::Template.register_tag('dropdown_menu', DropdownMenuBlock)
  Liquid::Template.register_tag('will_paginate', WillPaginateTag)
  Liquid::Template.register_tag('link_to_add_association', LinkToAddAssociationTag)
  Liquid::Template.register_tag('link_to_remove_association', LinkToRemoveAssociationTag)
  Liquid::Template.register_tag('title', TitleTag)
  Liquid::Template.register_tag('meta_description', MetaDescriptionTag)
  Liquid::Template.register_tag('query_graph', QueryGraphTag)
  Liquid::Template.register_tag('render_form', RenderFormTag)
  Liquid::Template.register_tag('placeholder', PlaceholderTag)

  def self.call(template)
    "LiquidView.new(self).render(#{template.source.inspect}, local_assigns)"
  end

  def self.sanitize_params(params)
    (params.presence || {}).except(*Rails.application.config.filter_parameters)
  end

  def initialize(view)
    @view = view
  end

  def render(source, local_assigns = {})
    controller.headers['Content-Type'] ||= content_type if controller.respond_to?(:headers)
    register_tags
    assigns = context_assigns.merge(local_assigns.stringify_keys)
    LiquidTemplateParser.new(
      filters: filters_from_controller(controller) + [Liquid::LiquidFilters],
      registers: { action_view: @view, controller: controller }
    ).parse(source, assigns).html_safe
  end

  def compilable?
    false
  end

  private

  def filters_from_controller(controller)
    if controller.respond_to?(:liquid_filters, true)
      controller.send(:liquid_filters)
    elsif controller.respond_to?(:master_helper_module)
      [controller.master_helper_module]
    else
      [controller._helpers]
    end
  end

  def register_tags(tags = tags_from_controller)
    tags.keys.each do |key|
      Liquid::Template.register_tag(key, tags.fetch(key))
    end
  end

  def tags_from_controller
    if controller.respond_to?(:liquid_tags, true)
      controller.send(:liquid_tags)
    else
      {}
    end
  end

  def context_assigns
    assigns = @view.assigns.reject { |k, _v| PROTECTED_ASSIGNS.include?(k) }
    # TODO: Move to GraphQL? g.system.*
    assigns['current_year'] = Date.current.year
    assigns['params'] = self.class.sanitize_params(@view.try(:controller).try(:params))
    assigns['current_url'] = @view.try(:controller).try(:request).try(:original_url)
    assigns['is_xhr_request'] = @view.try(:controller).try(:request).try(:xhr?) # TODO: Deduplicate
    assigns['request_xhr'] = @view.try(:controller).try(:request).try(:xhr?)
    assigns['current_path'] = @view.try(:controller).try(:request).try(:path)
    assigns['request_referer'] = @view.try(:controller).try(:request).try(:referer)
    assigns['current_full_path'] = @view.try(:controller).try(:request).try(:original_fullpath)
    assigns['current_user'] = @view.try(:controller).try(:current_user)
    assigns['flash'] = @view.try(:flash).try(:to_hash) if [ApplicationController, Api::BaseController].any? { |klass| @view.try(:controller).is_a?(klass) }
    assigns['form_authenticity_token'] = @view.try(:form_authenticity_token)

    custom_theme = PlatformContext.current.custom_theme
    if custom_theme.present?
      assigns['asset_url'] = Rails.cache.fetch("custom_themes.#{custom_theme.id}.#{custom_theme.updated_at}") do
        custom_theme.custom_theme_assets.each_with_object({}) do |custom_theme_asset, hash|
          hash[custom_theme_asset.name] = custom_theme_asset.file.url
        end
      end
    end

    if content_for_layout = @view.instance_variable_get('@content_for_layout')
      assigns['content_for_layout'] = content_for_layout
    elsif @view.content_for?(:layout)
      assigns['content_for_layout'] = @view.content_for(:layout)
    end
    assigns
  end

  def controller
    @view.controller
  end

  def content_type
    'text/html; charset=utf-8'
  end
end
