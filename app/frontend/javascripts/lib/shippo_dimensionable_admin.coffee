module.exports = ShippoDimensionableAdmin =

  updateUnitsOfMeasure: ->
    $('[data-js-element-identifier=admin_dimensions_template_select]').change =>
      form_unit_element = $('[data-js-element-identifier=admin_dimensions_template_select]')
      form_unit = 'imperial'
      if form_unit_element.length == 1
        form_unit = $(form_unit_element[0]).val()

      for item in ['weight', 'height', 'width', 'depth']
        select_element = $('[data-js-element-identifier=admin_dimensions_template_form_' + item + ']')
        select_element.empty()
        new_elements = @getOptionsTextByUnitType(form_unit, item)
        for new_element in new_elements
          select_element.append($("<option></option>").attr("value", new_element).text(new_element))

  getOptionsTextByUnitType: (unit_type, unit_name) ->
    result = []

    if $.inArray(unit_name, ['width', 'height', 'depth']) >= 0
      unit_name = 'length'

    for item in @units[unit_type][unit_name]
      result.push item

    return result
