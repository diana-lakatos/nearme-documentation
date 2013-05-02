class @Dashboard.ListingController

  constructor: (@container) ->
    new AvailabilityRulesController(@container)
    new PriceFields(@container)
    @submitLink = $('#submit-link')
    @container.find('#submit-input').hide()

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

  updateCurrency: () =>
      @currencyHolders.html($('#currency_'+ @currencySelect.val()).text())
