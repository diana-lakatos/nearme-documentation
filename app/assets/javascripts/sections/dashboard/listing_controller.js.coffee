class @Dashboard.ListingController

  constructor: (@container) ->
    @availabilityRules = new AvailabilityRulesController(@container)

    @currencySelect = @container.find('#currency-select')
    @locationRadios = @container.find('#location-list input[type="radio"]')
    @currencyHolders = @container.find('.currency-holder')
    @currencyLocationHolders = @container.find('.currency_addon')

    @enableSwitch = @container.find('#listing_enabled').parent().parent()
    @enableAjaxUpdate = true

    @initializePriceFields()
    @bindEvents()
    @updateCurrency()
    if ( @locationRadios.length > 0 )
      @updateCurrencyFromLocation()
    @setupDocumentRequirements()

  bindEvents: =>

    @setupBookingType()

    @container.on 'change', @currencySelect, (event) =>
      @updateCurrency()

    if ( @locationRadios.length > 0 )
      @locationRadios.on 'change', =>
        @updateCurrencyFromLocation()


    @enableSwitch.on 'switch-change', (e, data) =>
      enabled_should_be_changed_by_ajax = @enableSwitch.data('ajax-updateable')
      if enabled_should_be_changed_by_ajax?
        value = data.value
        if @enableAjaxUpdate
          url = @container.attr("action")
          if value
            url += '/enable'
          else
            url += '/disable'
          $.ajax
            url: url
            type: 'GET'
            dataType: 'JSON'
            error: (jq, textStatus, err) =>
              @enableAjaxUpdate = false
              @enableSwitch.find('#listing_enabled').siblings('label').trigger('mousedown').trigger('mouseup').trigger('click')
        else
          @enableAjaxUpdate = true


  updateCurrency: () =>
    @currencyHolders.html($('#currency_'+ @currencySelect.val()).text())

  updateCurrencyFromLocation: ->
    @currencyLocationHolders.html(@container.find('#location-list input[type="radio"]:checked').next().val())

  initializePriceFields: ->
    @priceFieldsFree = new PriceFields(@container.find('.price-inputs-free:first'))
    @priceFieldsHourly = new PriceFields(@container.find('.price-inputs-hourly:first'))
    @priceFieldsDaily = new PriceFields(@container.find('.price-inputs-daily:first'))


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
    bookingTypeInput = $('input[data-booking-type]')
    hourlyPrice = @container.find('div[data-hourly-price]')

    if bookingTypeInput.val() == 'overnight'
      hourlyPrice.hide()

    $('ul[data-booking-type-list] a[data-toggle="tab"]').on 'show.bs.tab', (e) =>
      bookingType = $(e.target).attr('data-booking-type')
      bookingTypeInput.val(bookingType)

      if bookingType == 'overnight'
        hourlyPrice.hide()
      else if bookingType == 'regular'
        hourlyPrice.show()
