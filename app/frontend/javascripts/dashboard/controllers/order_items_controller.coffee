module.exports = class OrderItemsController

  constructor: (el) ->
    @container = $(el)
    # @hour_inputs = @container.find('[data-quantity-input]')
    # @unit_price_input = @container.find('[data-price-input]')
    @allSubtotals = => @container.find('[data-subtotal]')
    @total = @container.find('.total .amount')

    @bindEvents()

  bindEvents: ->
    @calculateTotal()

    @container.on 'change', '[data-quantity-input]', (event) =>
      @calculateSubTotal($(event.target))

    @container.on 'change', '[data-price-input]', (event) =>
      @calculateSubTotal($(event.target))

    @container.on 'cocoon:before-remove', '.nested-fields-set',  (e,fields)=>
      $(fields).find('[data-subtotal]').data('amount', '0')
      @calculateTotal()

    @container.on 'cocoon:after-insert', '.nested-fields-set',  (e,fields)=>
      @calculateTotal()

  calculateSubTotal: (target)=>
    fieldset = target.parents('.nested-fields')
    if fieldset.find('[data-price-input]').length > 0
      price = parseFloat(fieldset.find('[data-price-input]').val())
    else
      price = 0

    if fieldset.find('[data-quantity-input]').length > 0
      quantity = parseFloat(fieldset.find('[data-quantity-input]').val())
    else
      quantity = 0

    newPrice = quantity * price
    subtotalField = fieldset.find('[data-subtotal]')
    subtotalField.text("#{subtotalField.data('currency')}#{newPrice.toFixed(2)}")
    subtotalField.data('amount', newPrice.toFixed(2))
    @calculateTotal()

  calculateTotal: =>
    totalPrice = 0
    for subtotal in @allSubtotals()
      totalPrice += parseFloat($(subtotal).data('amount'))
    @total.text("#{@total.data('currency')}#{totalPrice.toFixed(2)}")

