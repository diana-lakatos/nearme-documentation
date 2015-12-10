JavascriptModule = require('../../lib/javascript_module');
ShippoDimensionable = require('../../lib/shippo_dimensionable');

module.exports = class ShippoFieldsManager extends JavascriptModule
  @include ShippoDimensionable

  constructor: (units) ->
    @units = units
    @toggle_shippo_fields_by_checked_status()
    $('[data-js-element-identifier="product_form_shippo_enabled"]').click =>
      @toggle_shippo_fields_by_checked_status()
      return

    @updateDimensionsFieldsFromTemplates()

    if $('form#product_form').data('new-record') && $('#product_errors_present').length == 0
      @setDefaultOptionAsSelected()

    $('[data-js-element-identifier="product_form_templates_list"]').trigger('change')

  setDefaultOptionAsSelected: ->
    $('[data-js-element-identifier="product_form_templates_list"] option').each ->
      if typeof($(this).attr('data-template')) != 'undefined'
        data_options = jQuery.parseJSON($(this).attr('data-template'))
        if data_options['use_as_default']
          $('[data-js-element-identifier="product_form_templates_list"]').val($(this).val())

  toggle_shippo_fields_by_checked_status: ->
    shippo_fields_element = $(".shippo_required_fields_row")
    shippo_checkbox_element = $('[data-js-element-identifier="product_form_shippo_enabled"]')
    shipping_profile_fields = $('[data-js-element-identifier="initial_shipping_profiles_section"]')
    if (shippo_checkbox_element.length > 0) and shippo_checkbox_element.is(":checked")
      shippo_fields_element.removeClass "disabled"
      shippo_fields_element.addClass "enabled"
      if shipping_profile_fields.length > 0
        shipping_profile_fields.removeClass "enabled"
        shipping_profile_fields.addClass "disabled"
    else
      shippo_fields_element.removeClass "enabled"
      shippo_fields_element.addClass "disabled"
      if shipping_profile_fields.length > 0
        shipping_profile_fields.removeClass "disabled"
        shipping_profile_fields.addClass "enabled"
    return
