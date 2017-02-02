JavascriptModule = require('../lib/javascript_module')
ShippoDimensionable = require('../lib/shippo_dimensionable')

module.exports = class RentalShippingTypeSelector extends JavascriptModule
  @include ShippoDimensionable

  constructor: (select, dimensionsTemplatesContainer, units) ->
    @units = units
    @select = select
    @dimensionsTemplatesContainer = dimensionsTemplatesContainer

    @updateDimensionsFieldsFromTemplates()

    select.on 'change', =>
      @toggleDimensionsContainer()

    setTimeout (=>
      @toggleDimensionsContainer()
      return
    ), 200

  toggleDimensionsContainer: ->
    if @select.val() == 'delivery' || @select.val() == 'both'
      @dimensionsTemplatesContainer.show()
      $('input[data-remove-object]').val('')
    else
      @dimensionsTemplatesContainer.hide()
      $('input[data-remove-object]').val('1')

