module.exports = ShippoDimensionable =
  updateDimensionsFieldsFromTemplates: ->
    $(document).on 'change', '[data-js-element-identifier="product_form_templates_list"]', =>
      selected_template_option = $('[data-js-element-identifier="product_form_templates_list"]').find(':selected')
      if typeof(selected_template_option.attr('data-template')) != 'undefined'
        data_options = jQuery.parseJSON(selected_template_option.attr('data-template'))
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
              select_element.append($("<option selected></option>").attr("value", new_element).text(new_element))
            else
              select_element.append($("<option></option>").attr("value", new_element).text(new_element))
          select_element.trigger('change')

  getOptionsTextByUnitType: (unit_type, unit_name) ->
    result = []

    if $.inArray(unit_name, ['width', 'height', 'depth']) >= 0
      unit_name = 'length'

    for item in @units[unit_type][unit_name]
      result.push item

    return result
