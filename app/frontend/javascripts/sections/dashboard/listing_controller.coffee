AvailabilityRulesController = require('../../components/availability_rules_controller')
SetupNestedForm = require('../setup_nested_form')
PriceFields = require('../../components/price_fields')

module.exports = class DashboardListingController

  constructor: (@container) ->
    @availabilityRules = new AvailabilityRulesController(@container)

    @currencySelect = @container.find('#currency-select')
    @locationRadios = @container.find('#location-list input[type="radio"]')
    @currencyHolders = @container.find('.currency-holder')
    @currencyLocationHolders = @container.find('.currency_addon')
    @defalt_currency = @container.find('#default_currency').text()

    @enableSwitch = @container.find('#listing_enabled').parent().parent()
    @enableAjaxUpdate = true

    @initializePriceFields()
    @bindEvents()
    @updateCurrency()
    @setupDocumentRequirements()

  bindEvents: =>

    @setupBookingType()

    @container.on 'change', @currencySelect, (event) =>
      @updateCurrency()

    @setupTooltips()


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

  setupTooltips: ->
    if $('.no_trust_explanation_needed').length > 0
      $('.no_trust_explanation_needed .bootstrap-switch-wrapper').attr('data-original-title', $('.no_trust_explanation_needed').attr('data-explanation'))
      $('.no_trust_explanation_needed .bootstrap-switch-wrapper').tooltip
        trigger: 'hover'

  updateCurrency: =>
    @currencyHolders.html($('#currency_'+ (@currencySelect.val() || @defalt_currency)).text())
    @currencyLocationHolders.html($('#currency_'+ (@currencySelect.val() || @defalt_currency)).text())

  initializePriceFields: ->
    @priceFieldsFree = new PriceFields(@container.find('.price-inputs-free:first'))
    @priceFieldsHourly = new PriceFields(@container.find('.price-inputs-hourly:first'))
    @priceFieldsDaily = new PriceFields(@container.find('.price-inputs-daily:first'))
    @priceFieldsSubscription = new PriceFields(@container.find('.price-inputs-subscription:first'))


    @freeInput = @container.find('.price-inputs-free').find('input:checkbox:first')
    @dailyInput = @container.find('.price-inputs-daily').find('input:checkbox:first')
    @hourlyInput = @container.find('.price-inputs-hourly').find('input:checkbox:first')
    @subscriptionInput = @container.find('.price-inputs-subscription').find('input:checkbox:first')

    @hideNotCheckedPriceFields()

    @freeInput.on 'change', (e) =>
      @togglePriceFields()

    @hourlyInput.on 'change', (e) =>
      @freeInput.prop('checked', false)
      @togglePriceFields()

    @dailyInput.on 'change', (e) =>
      @freeInput.prop('checked', false)
      @togglePriceFields()

    @subscriptionInput.on 'change', (e) =>
      @freeInput.prop('checked', false)
      @togglePriceFields()

  togglePriceFields: ->
    if @freeInput.is(':checked')
      @priceFieldsFree.show()
      @dailyInput.prop('checked', false)
      @hourlyInput.prop('checked', false)
      @subscriptionInput.prop('checked', false)
    if @hourlyInput.is(':checked')
      @priceFieldsHourly.show()
    if @dailyInput.is(':checked')
      @priceFieldsDaily.show()
    if @subscriptionInput.is(':checked')
      @priceFieldsSubscription.show()

    @hideNotCheckedPriceFields()

  hideNotCheckedPriceFields: ->
    @priceFieldsFree.hide() unless @freeInput.is(':checked')
    @priceFieldsHourly.hide() unless @hourlyInput.is(':checked')
    @priceFieldsDaily.hide() unless @dailyInput.is(':checked')
    @priceFieldsSubscription.hide() unless @subscriptionInput.is(':checked')

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
    for period in ['hourly', 'daily', 'weekly', 'monthly', 'subscription']
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
