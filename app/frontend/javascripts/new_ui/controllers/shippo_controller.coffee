module.exports = class ShippoController
  constructor: (container) ->
    @container = $(container)
    @dimension_templates = @container.find('[data-dimension-templates]')
    @enabled_switch = @container.find('[data-shipping-enabled]')
    @fields = $('.shippo-fields')
    @bindEvents()
    @initialize()

  bindEvents: ->
    @enabled_switch.on 'click', =>
      @toggleShippoFieldsByCheckedStatus()

    $(window).on 'load', =>
      @toggleShippoFieldsByCheckedStatus()

  initialize: ->


  toggleShippoFieldsByCheckedStatus: ->
    state = @enabled_switch.is(':checked')
    @fields.toggleClass('form-section-disabled', !state)
    @dimension_templates.trigger('toggle.dimensiontemplates', [state])
