class @RentalShippingTypeSelector extends @JavascriptModule
  @include ShippoDimensionable

  constructor: (select, dimensionsTemplatesContainer, units) ->
    @units = units
    @select = select
    @dimensionsTemplatesContainer = dimensionsTemplatesContainer

    @updateDimensionsFieldsFromTemplates()

    select.on 'change', =>
      @toggleDimensionsContainer()

    setTimeout (=>
      @changeDefaultRentalTypeToDelivery()
      @toggleDimensionsContainer()
      return
    ), 200

  # We do this from JS to avoid interfering with Rails' default which
  # needs to be "not rental"
  changeDefaultRentalTypeToDelivery: () ->
    if $('[data-rental-shipping-type]').data('initial-render') == true
      $('[data-rental-shipping-type] option[value="delivery"]').prop('selected', true)
      $('[data-rental-shipping-type]').trigger('render')

  toggleDimensionsContainer: () ->
    if @select.val() == 'delivery' || @select.val() == 'both'
      @dimensionsTemplatesContainer.show()
      $('input[data-remove-object]').val('')
    else
      @dimensionsTemplatesContainer.hide()
      $('input[data-remove-object]').val('1')

