module.exports = class DeliveryController
  constructor: (el) ->
    @container = $(el)
    @shipping_rule = @container.find('.order_shipments_shipping_rule_id input')
    @shipping_address = @container.find('[data-shipping-address]')
    @toggleFields(@shipping_rule.filter(':checked'))
    @bindEvents()

  bindEvents: ->
    @shipping_rule.on 'change', (e) =>
      @toggleFields($(e.target))

  toggleFields: (element) ->
    if element.data('is-pickup') == true
      @shipping_address.hide()
      @shipping_address.find('select, input, checkbox').prop('disabled', true)
    else
      @shipping_address.show()
      @shipping_address.find('select, input, checkbox').prop('disabled', false)