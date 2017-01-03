# frozen_string_literal: true
require 'rdiscount'
module AdminHelper
  def admin_help_area(slug)
    options = {}
    options[:class] = 'config-section-description'

    position = current_user.get_ui_setting('help-position')

    options[:data] = {}
    options[:style] = ''

    if position
      options[:data] = { 'offset-x': position[0], 'offset-y': position[1] }

      if current_user.get_ui_setting('help-is-detached')
        options[:style] = "transform: translate(#{position[0]}px, #{position[1]}px);"
      end
    end

    help_content = HelpContent.find_by(slug: slug) || (Rails.env.test? && HelpContent.new(id: 0, content: ''))

    raise "Missing help content object for: '#{slug}'" unless help_content

    content_for(:help) do
      content_tag(:div, options) do
        out = ActiveSupport::SafeBuffer.new
        if current_user.admin?
          out << content_tag(:div, class: 'help-options') do
            link_to t('admin.help.edit'), edit_admin_help_content_path(help_content), class: 'btn help-option-button help-edit', "data-help-content": help_content.id
          end
        end

        markdown = ::RDiscount.new(help_content.content)
        out << content_tag(:div, markdown.to_html.html_safe, 'data-help-container': '')
      end
    end
  end

  def admin_versions_link(url, apiEndpoint)
    apiEndpoint = apiEndpoint.is_a?(String) ? apiEndpoint : url_for(apiEndpoint)

    link_to t('admin.versions.trigger.label'), url,
            title: t('admin.versions.trigger.title'),
            class: 'btn btn-flat btn-versions',
            data: { 'versions-modal': true, 'editor-selector': '[data-main-editor]', 'api-endpoint': apiEndpoint }
  end

  def admin_side_navigation(context)
    content_for :section_navigation do
      content_tag('nav', class: 'nav-side select-navigation', 'aria-labelledby': 'sidenav-title') do
        out = ActiveSupport::SafeBuffer.new
        out << content_tag('h2', t(context, scope: [:admin, :sidenav, :heading]), id: 'sidenav-title')
        out << render_navigation(context)
        out
      end
    end
  end

  def render_navigation(context)
    items = send("admin_navigation_#{context}".to_sym)
    content_tag('ul') do
      out = ActiveSupport::SafeBuffer.new
      items.each do |item|
        highlights_on = item[:highlights_on] || "^#{Regexp.escape(item[:url])}$"
        out << content_tag('li', class: (Regexp.new(highlights_on).match(request.env['PATH_INFO']) ? 'selected' : nil)) do
          link_to item[:name], item[:url]
        end
      end
      out
    end
  end

  def admin_delete_action(url, options = {})
    url = url.is_a?(String) ? url : url_for(url)
    name = block_given? ? capture { yield } : t('admin.general.actions.delete')

    options ||= {}
    options[:prompt] ||= options[:object_name] ? t('admin.general.confirm_delete.prompt_object', object_name: options[:object_name]) : t('admin.general.confirm_delete.prompt')
    options[:yes] ||= t('admin.general.confirm_delete.yes')
    options[:no] ||= t('admin.general.confirm_delete.no')

    # You might be tempted to move name to first param. Don't, we want a <button> and not an <input> and this is the only way to do it
    button_to url, method: 'delete', form: {
      'data-confirm' => options[:prompt],
      'data-confirm-label-yes' => options[:yes],
      'data-confirm-label-no' => options[:no]
    }, class: 'btn btn-delete' do
      name
    end
  end

  def admin_simple_form_for(record, options = {}, &block)
    options[:wrapper] = :admin_form
    options[:error_class] = :field_with_error
    options[:html] = options[:html] || {}

    case record
    when String, Symbol
      object_name = record
      object      = nil
    else
      object      = record.is_a?(Array) ? record.last : record
      raise ArgumentError, 'First argument in form cannot contain nil or be empty' unless object
      object_name = options[:as] || model_name_from_record_or_class(object).param_key
    end

    options[:html][:"data-object-name"] = object_name

    options[:wrapper_mappings] = {
      check_boxes: :admin_radio_and_checkboxes,
      radio_buttons: :admin_radio_and_checkboxes,
      file: :admin_file_input,
      boolean: :admin_boolean,
      switch: :admin_switch,
      inline_form: :admin_inline_form,
      limited_string: :admin_form,
      limited_text: :admin_form,
      tel: :admin_addon,
      price: :admin_form,
      select: :admin_select,
      combobox: :admin_combobox
    }
    simple_form_for(record, options, &block)
  end

  private

  def admin_navigation_advanced
    [
      { name: 'Domains', url: admin_advanced_domains_path },
      { name: 'User Profiles', url: admin_path(page: 'advanced_wizard_user_profiles') },
      { name: 'User Roles', url: admin_path(page: 'advanced_wizard_user_roles') },
      { name: 'Home Search', url: admin_path(page: 'advanced_wizard_home_search') },
      { name: 'Wish Lists', url: admin_path(page: 'advanced_wizard_wishlists') },
      { name: 'Reviews', url: admin_path(page: 'advanced_wizard_reviews') },
      { name: 'Transactional Emails', url: admin_path(page: 'advanced_wizard_emails') },
      { name: 'Text Messages / SMS', url: admin_path(page: 'advanced_wizard_sms') },
      { name: 'Text Filters', url: admin_path(page: 'advanced_wizard_text_filters') },
      { name: 'Support Email', url: admin_path(page: 'advanced_wizard_support_email') },
      { name: 'Custom Attributes', url: admin_path(page: 'advanced_wizard_custom_attributes') },
      { name: 'Validations', url: admin_path(page: 'advanced_wizard_validations') },
      { name: 'Bulk data upload', url: admin_path(page: 'advanced_wizard_bulk') },
      { name: 'Graph Queries', url: admin_advanced_graph_queries_path }
    ]
  end

  def admin_navigation_asset
    [
      { name: 'General Settings', url: admin_assets_general_settings_path(@transactable_type) },
      { name: 'Properties', url: admin_path(page: 'asset_wizard_properties') },
      { name: 'Location', url: admin_path(page: 'asset_wizard_location') },
      { name: 'Booking', url: admin_path(page: 'asset_wizard_booking') },
      { name: 'Pricing', url: admin_path(page: 'asset_wizard_pricing') },
      { name: 'Shipping', url: admin_path(page: 'asset_wizard_shipping') },
      { name: 'Taxes', url: admin_path(page: 'asset_wizard_taxes') },
      { name: 'Payments', url: admin_path(page: 'asset_wizard_payments') },
      { name: 'Waiver Agreements', url: admin_path(page: 'asset_wizard_waiver_agreements') },
      { name: 'File Uploads', url: admin_path(page: 'asset_wizard_file_uploads') },
      { name: 'Search', url: admin_path(page: 'asset_wizard_search') },
      { name: 'Form layouts', url: admin_path(page: 'asset_wizard_form_layouts') },
      { name: 'WTF', url: admin_path(page: 'asset_wizard_wtf') },
      { name: 'Delete Asset', url: admin_path(page: 'asset_delete') }
    ]
  end

  def admin_navigation_design
    [
      { name: 'Themes', url: admin_design_themes_path, highlights_on: /admin\/design\/(themes|templates)(\/.+)*/ },
      { name: 'Pages', url: admin_design_pages_path, highlights_on: /admin\/design\/pages(\/.+)*/ },
      { name: 'Content Holders', url: admin_design_content_holders_path },
      { name: 'Manage files', url: admin_design_files_path }
    ]
  end

  def admin_navigation_integrations
    [
      { name: 'API', url: '#' },
      { name: 'Authentication', url: '#' },
      { name: 'Google Analytics', url: '#' },
      { name: 'Shippo', url: '#' },
      { name: 'Olark', url: '#' },
      { name: 'Twilio', url: '#' }
    ]
  end

  def admin_navigation_marketplace
    [
      { name: 'General Settings', url: admin_path(page: 'marketplace_wizard_general') },
      { name: 'Users', url: admin_path(page: 'marketplace_wizard_users') },
      { name: 'Languages', url: admin_path(page: 'marketplace_wizard_languages') }
    ]
  end

  def admin_limit_content_width(state = true)
    @admin_limit_content_width = state
  end

  def admin_limit_content_width?
    @admin_limit_content_width.present? && @admin_limit_content_width
  end

  def admin_file_type_icon(file_type)
    icons = %w(3gp 7z ae ai apk asf avi bak bmp cdr css csv divx dll doc docx dw dwg eps exe flv fw gif gz html ico iso jar jpg js mov mp3 mp4 mpeg pdf php png ppt ps psd rar svg swf sys tar tiff txt wav zip)

    file_type = 'unknown' unless icons.include? file_type

    content_tag(:svg, class: 'file-type-icon') do
      content_tag('use', nil, 'xlink:href': "#{image_url('admin/file-type-icons/symbol-defs.svg')}##{file_type}-file-type")
    end
  end
end
