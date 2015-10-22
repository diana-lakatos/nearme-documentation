# TODO: file probably won't be used. DELETE
class @DNM.Listings.Controller

  constructor: (@container) ->
    @availabilityRules = new DNM.Listings.AvailabilityRulesController(@container)

    @currencySelect = @container.find('#currency-select')
    @locationRadios = @container.find('#location-list input[type="radio"]')
    @currencyHolders = @container.find('.currency-holder')
    @currencyLocationHolders = @container.find('.currency_addon')
    @defalt_currency = @container.find('#default_currency').text()

    @enableSwitch = @container.find('#listing_enabled').parent().parent()
    @enableAjaxUpdate = true

    @bindEvents()

    @initializePriceFields()
    @setupBookingType()

    @updateCurrency()
    @setupDocumentRequirements()

  bindEvents: =>
    @container.on 'change', @currencySelect, (event) =>
      @updateCurrency()

  updateCurrency: () =>
    @currencyHolders.html($('#currency_'+ (@currencySelect.val() || @defalt_currency)).text())
    @currencyLocationHolders.html($('#currency_'+ (@currencySelect.val() || @defalt_currency)).text())

  initializePriceFields: ->
    @priceFieldsFree = new DNM.Listings.PriceFields(@container.find('.price-inputs-free:first'))
    @priceFieldsHourly = new DNM.Listings.PriceFields(@container.find('.price-inputs-hourly:first'))
    @priceFieldsDaily = new DNM.Listings.PriceFields(@container.find('.price-inputs-daily:first'))


    @freeInput = @container.find('.price-inputs-free').find('input:checkbox:first')
    @dailyInput = @container.find('.price-inputs-daily').find('input:checkbox:first')
    @hourlyInput = @container.find('.price-inputs-hourly').find('input:checkbox:first')

    @hideNotCheckedPriceFields()

    @freeInput.on 'change', (e) =>
      @togglePriceFields()

    @hourlyInput.on 'change', (e) =>
      @freeInput.prop('checked', false)
      @togglePriceFields()

    @dailyInput.on 'change', (e) =>
      @freeInput.prop('checked', false)
      @togglePriceFields()

  togglePriceFields: ->
    if @freeInput.is(':checked')
      @priceFieldsFree.show()
      @dailyInput.prop('checked', false)
      @hourlyInput.prop('checked', false)
    if @hourlyInput.is(':checked')
      @priceFieldsHourly.show()
    if @dailyInput.is(':checked')
      @priceFieldsDaily.show()

    @hideNotCheckedPriceFields()

  hideNotCheckedPriceFields: ->
    @priceFieldsFree.hide() unless @freeInput.is(':checked')
    @priceFieldsHourly.hide() unless @hourlyInput.is(':checked')
    @priceFieldsDaily.hide() unless @dailyInput.is(':checked')

  setupDocumentRequirements: ->
    nestedForm = new SetupNestedForm(@container)
    nestedForm.setup(".remove-document-requirement:not(:first)",
                ".document-hidden", ".remove-document",
                ".document-requirement",
                ".document-requirements .add-new", true)

  setupBookingType: =>
    @periodInputs = {}
    @allPeriodsLabel = $('div[data-all-periods-label]')
    @dailyLabel = $('div[data-daily-label]')
    @bookingTypeInput = $('input[data-booking-type]')
    for period in ['hourly', 'daily', 'weekly', 'monthly']
      @periodInputs[period] = @container.find("div[data-period=\"#{period}\"]")
    @changeBookingType($('ul[data-booking-type-list] li.active a[data-toggle="tab"]'))

    $('ul[data-booking-type-list] a[data-toggle="tab"]').on 'show.bs.tab', (e) =>
      @changeBookingType(e.target)

  changeBookingType: (target) =>
    if $(target).length > 0
      bookingType = $(target).attr('data-booking-type')
      @bookingTypeInput.val(bookingType)
      if bookingType == 'overnight'
        @periodInputs.hourly.hide()
      else
        @periodInputs.hourly.show()

      if bookingType == 'recurring'
        @periodInputs.weekly.hide()
        @periodInputs.monthly.hide()
        @allPeriodsLabel.hide()
        @dailyLabel.show()
      else
        @periodInputs.weekly.show()
        @periodInputs.monthly.show()
        @allPeriodsLabel.show()
        @dailyLabel.hide()
