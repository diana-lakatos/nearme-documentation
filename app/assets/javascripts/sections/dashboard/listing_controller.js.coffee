class @Dashboard.ListingController

  constructor: (@container) ->
    @availabilityRules = new AvailabilityRulesController(@container)
    @submitLink = $('#submit-link')
    @container.find('#submit-input').hide()

    @currencySelect = @container.find('#currency-select')
    @currencyHolders = @container.find('.currency-holder')

    @initializePriceFields()
    @bindEvents()
    @updateCurrency()

  bindEvents: =>

    @container.on 'change', @currencySelect, (event) =>
      @updateCurrency()

    @submitLink.on 'click',  =>
      @container.submit()
      false

  updateCurrency: () =>
      @currencyHolders.html($('#currency_'+ @currencySelect.val()).text())

  initializePriceFields: ->
    @priceFieldsHourly = new PriceFields(@container.find('.price-inputs-hourly'))
    @priceFieldsDaily = new PriceFields(@container.find('.price-inputs-daily'))

    @dailyInput = @container.find('.price-inputs-daily').find('input[type="radio"]')
    @hourlyInput = @container.find('.price-inputs-hourly').find('input[type="radio"]')

    @hourlyInput.on 'change', (e) =>
      @togglePriceFields()

    @dailyInput.on 'change', (e) =>
      @togglePriceFields()

    @togglePriceFields()

  togglePriceFields: ->
    if @dailyInput.is(':checked')
      @priceFieldsHourly.hide()
      @priceFieldsDaily.show()
    else
      @priceFieldsHourly.show()
      @priceFieldsDaily.hide()

