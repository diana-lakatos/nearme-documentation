class @ShippoFieldsManager
  constructor: (units) ->
    @units = units
    @toggle_shippo_fields_by_checked_status()
    $('[data-js-element-identifier="product_form_shippo_enabled"]').click =>
      @toggle_shippo_fields_by_checked_status()
      return
    $('[data-js-element-identifier="product_form_templates_list"]').change =>
      selected_template_option = $('[data-js-element-identifier="product_form_templates_list"]').find(':selected')
      if typeof(selected_template_option.attr('data-template')) != 'undefined'
        data_options = jQuery.parseJSON(selected_template_option.attr('data-template'));
      else
        data_options = null

      if data_options
        $('[data-js-element-identifier="product_form_unit_of_measure"]').val(data_options['unit_of_measure'])
        for item in ['weight', 'height', 'width', 'depth']
          select_element = $('[data-js-element-identifier="product_form_input_' + item + '_unit"]')
          select_element.empty()
          new_elements = @getOptionsTextByUnitType(data_options['unit_of_measure'], item)
          $('[data-js-element-identifier="product_form_input_' + item + '"]').val(data_options[item])
          for new_element in new_elements
            if data_options[item + '_unit'] == new_element
              select_element.append($("<option selected></option>").attr("value", new_element).text(new_element));
            else
              select_element.append($("<option></option>").attr("value", new_element).text(new_element));
          select_element.trigger('change')

    if $('form#product_form').data('new-record') && $('#product_errors_present').length == 0
      @setDefaultOptionAsSelected()

    $('[data-js-element-identifier="product_form_templates_list"]').trigger('change')

  setDefaultOptionAsSelected: ->
    $('[data-js-element-identifier="product_form_templates_list"] option').each ->
      if typeof($(this).attr('data-template')) != 'undefined'
        data_options = jQuery.parseJSON($(this).attr('data-template'))
        if data_options['use_as_default']
          $('[data-js-element-identifier="product_form_templates_list"]').val($(this).val())

  getOptionsTextByUnitType: (unit_type, unit_name) ->
    result = []

    if $.inArray(unit_name, ['width', 'height', 'depth']) >= 0
      unit_name = 'length'

    for item in @units[unit_type][unit_name]
      result.push item

    return result


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
