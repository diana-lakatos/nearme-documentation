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
    @priceFieldsFree = new PriceFields(@container.find('.price-inputs-free'))
    @priceFieldsHourly = new PriceFields(@container.find('.price-inputs-hourly'))
    @priceFieldsDaily = new PriceFields(@container.find('.price-inputs-daily'))


    @freeInput = @container.find('.price-inputs-free').find('input[type="radio"]')
    @dailyInput = @container.find('.price-inputs-daily').find('input[type="radio"]')
    @hourlyInput = @container.find('.price-inputs-hourly').find('input[type="radio"]')

    @hideNotCheckedPriceFields()

    @freeInput.on 'change', (e) =>
      @togglePriceFields()

    @hourlyInput.on 'change', (e) =>
      @togglePriceFields()

    @dailyInput.on 'change', (e) =>
      @togglePriceFields()

  togglePriceFields: ->
    if @freeInput.is(':checked')
      @priceFieldsFree.show()
      @priceFieldsHourly.hide()
      @priceFieldsDaily.hide()
    else if @hourlyInput.is(':checked')
      @priceFieldsFree.hide()
      @priceFieldsHourly.show()
      @priceFieldsDaily.hide()
    else if @dailyInput.is(':checked')
      @priceFieldsFree.hide()
      @priceFieldsHourly.hide()
      @priceFieldsDaily.show()

  hideNotCheckedPriceFields: ->
    @priceFieldsFree.hide() unless @freeInput.is(':checked')
    @priceFieldsHourly.hide() unless @hourlyInput.is(':checked')
    @priceFieldsDaily.hide() unless @dailyInput.is(':checked')
