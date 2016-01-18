class @DNM.RentalShippingTypesController
  constructor: (container) ->
    @container = $(container)
    @fields = @container.find('.rental-shipping-type-section__fields')
    @typeSelect = @container.find('[data-rental-shipping-type]')
    @dimensionTemplates = @container.find('[data-dimension-templates]')
    @removeField = @container.find('input[data-remove-object]')
    @insuranceField = @container.find('[data-insurance]')
    @bindEvents()

  bindEvents: ->
    @typeSelect.on 'change', @toggleDimensionsContainer
    $(window).on 'load', @toggleDimensionsContainer

  toggleDimensionsContainer: =>
    state = $.inArray(@typeSelect.val(), ['delivery','both']) > -1

    if state then @insuranceField.removeAttr('readonly') else @insuranceField.attr('readonly', 'readonly')

    @fields.toggleClass('form-section-disabled', !state)
    @dimensionTemplates.trigger('toggle.dimensiontemplates', [state])
    if state
      @removeField.val('')
    else
      @removeField.val(1)


$('.rental-shipping-type-section').each ->
  new DNM.RentalShippingTypesController(@)
