module.exports = class CompleteReservationController

  constructor: (el) ->
    @container = $(el)
    @hour_inputs = @container.find('[data-hours-input]')
    @allSubtotals = => @container.find('[data-subtotal]')
    @total = @container.find('.total .amount')

    @bindEvents()

  bindEvents: ->
    @calculateTotal()

    @container.on 'change', '[data-hours-input]', (event) =>
      @calculateSubTotal($(event.target))

    @container.on 'cocoon:before-remove', '.nested-fields-set',  (e,fields) =>
      $(fields).find('[data-subtotal]').data('amount', '0')
      @calculateTotal()

    @container.on 'cocoon:after-insert', '.nested-fields-set',  (e,fields) =>
      @calculateTotal()

  calculateSubTotal: (target) =>
    fieldset = target.parents('.nested-fields')
    if fieldset.find('.rate').length > 0
      rate = parseInt(fieldset.find('.rate').data('amount')) / 100
    else
      rate = 1
    newPrice = parseFloat(target.val()) * rate
    subtotalField = fieldset.find('[data-subtotal]')
    subtotalField.text("#{subtotalField.data('currency')}#{newPrice.toFixed(2)}")
    subtotalField.data('amount', newPrice.toFixed(2))
    @calculateTotal()

  calculateTotal: =>
    totalPrice = 0
    for subtotal in @allSubtotals()
      totalPrice += parseFloat($(subtotal).data('amount'))
    @total.text("#{@total.data('currency')}#{totalPrice.toFixed(2)}")

