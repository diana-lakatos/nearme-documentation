class @Dashboard.ListingController

  constructor: (@container) ->
    new AvailabilityRulesController(@container)
    @submitLink = $('#submit-link')
    @container.find('#submit-input').hide()

    @priceInputs = @container.find('input[name*=price]')
    @freeCheckbox = @container.find('input[type=checkbox][name*=free]')
    @currencySelect = @container.find('#currency-select')
    @currencyHolders = @container.find('.currency-holder')

    @bindEvents()
    @updateCurrency()

  bindEvents: =>

    @container.on 'change', @currencySelect, (event) =>
      @updateCurrency()

    @submitLink.on 'click',  =>
      @container.submit()
      false

    @container.on 'keyup change blur', 'input[name*=daily_price], input[name*=weekly_price], input[name*=monthly_price]', (event) =>
      @priceChanged(event)

    @container.on 'change', 'input[type=checkbox][name*=free]', =>
      @freeChanged()

  updateCurrency: () =>
      @currencyHolders.html($('#currency_'+ @currencySelect.val()).text())


  freeChanged: ->
    if @freeCheckbox.prop('checked')
      @priceInputs.val('')
    else
      @priceInputs.eq(0).focus().val('')

  priceChanged: (event) ->
    prices = (parseFloat(priceInput.value) for priceInput in @priceInputs)
    (if price > 0 then checkFree = false) for price in prices
    if checkFree != false then checkFree = true
    @freeCheckbox.prop('checked', checkFree)
