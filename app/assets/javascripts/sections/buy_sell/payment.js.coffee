class @PaymentController

  constructor: (@container) ->
    @bindEvents()
    @totalPrice = @container.find('[data-total-price]')

  bindEvents: =>
    @container.find('[data-upload-document]').on 'click', (e) ->
      $(@).closest('[data-upload]').find('input[type=file]').click()

    @container.find('input[type=file]').on 'change', (e) ->
      span = $(@).closest('[data-upload]').find('[data-file-name]')
      fileName = $(@).val().split(/(\\|\/)/g).pop()
      span.html(fileName)

    @container.find('[data-additional-charges]').on 'change', (e) =>
      target = $(e.target)
      current_price = parseFloat(@totalPrice.html())
      charge_price = parseFloat(target.closest('[data-additional-charge-wrapper]').find('[data-additional-charge-price]').html())
      if target.is(':checked')
        new_price = current_price + charge_price
      else
        new_price = current_price - charge_price
      @totalPrice.html(new_price.toFixed(2))

