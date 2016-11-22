require 'selectize/dist/js/selectize'

# Handles the behaviour of entering country+mobile+phone fields
# Used on the user account form, booking modal and the space setup wizard form.
module.exports = class PhoneNumbers

  constructor: (@container, {@countrySelector, @codeSelector, @mobileSelector, @phoneSelector, @sameAsSelector} = {}) ->
    _.defaults @,
      container          : $('div[data-phone-fields-container]')
      countrySelector    : 'select[data-country-selector]'
      codeSelector       : '.input-group-addon'
      mobileSelector     : 'input[data-mobile-number]'
      phoneSelector      : 'input[data-phone]'
      sameAsSelector     : 'input[data-same-as-phone-checkbox]'
      ctcTriggerSelector : 'a[data-ctc-trigger]'

    return unless @container.length > 0

    @findFields()
    @bindEvents()

    interval = window.setInterval(()=>
      if @countryNameField[0].selectize
        window.clearInterval(interval)
        @updateCountryCallingCode()
        @updatePhoneNumber()
        @updateCtcTrigger()
    , 50)

  findFields: ->
    @countryNameField  = @container.find(@countrySelector)
    @callingCodeText   = @container.find(@codeSelector)
    @mobileNumberField = @container.find(@mobileSelector)
    @phoneNumberField  = @container.find(@phoneSelector)
    @sameAsPhoneField  = @container.find(@sameAsSelector)
    @ctcTrigger        = @container.find(@ctcTriggerSelector)

  bindEvents: ->
    @container.on 'change', @countrySelector, ()=>
      @updateCountryCallingCode()

    @container.on 'change keyup', "[type='tel']", ()=>
      @updatePhoneNumber()

    @container.on 'change', @sameAsSelector, ()=>
      @updatePhoneNumber()

    @ctcTrigger.on 'click', (e)=>
      e.preventDefault()
      $(document).trigger 'load:dialog.nearme', [{ url: @ctcTrigger.attr('href'), data: @ctcTrigger.data('ajax-options') }, null, {
        onHide: @updateCtcTriggerState
      }]

    @phoneNumberField.closest('.disabled-catch-container').find('.click-catcher').on 'click', (e) =>
      if @phoneNumberField.prop('disabled')
        value = @phoneNumberField.data('disabled-field-notice')
        if value
          alert(value)

    @mobileNumberField.closest('.disabled-catch-container').find('.click-catcher').on 'click', (e) =>
      if @mobileNumberField.prop('disabled')
        value = @mobileNumberField.data('disabled-field-notice')
        if value
          alert(value)

  updatePhoneNumber: ->
    @mobileNumberField.prop('readonly', !!@isMobileSameAsPhone())
    @mobileNumberField.val(@phoneNumberField.val()) if @isMobileSameAsPhone()
    @updateCtcTrigger()

  isMobileSameAsPhone: ->
    @sameAsPhoneField.is(':checked')

  getCountryCode: ->
    current = @countryNameField[0].selectize.items[0]
    return @countryNameField[0].selectize.options[current].callingCode if current

  updateCountryCallingCode: ->

    code = @getCountryCode()

    code = if code
      "+#{code}"
    else
      ""
    @callingCodeText.text(code)

    isDisabled = code is ""

    @mobileNumberField.prop('disabled', isDisabled).closest('.form-group').toggleClass('disabled', isDisabled)
    @phoneNumberField.prop('disabled', isDisabled).closest('.form-group').toggleClass('disabled', isDisabled)

    if isDisabled
      @mobileNumberField.attr('placeholder', @mobileNumberField.data('disabled-field-notice'))
      @phoneNumberField.attr('placeholder', @mobileNumberField.data('disabled-field-notice'))
    else
      @mobileNumberField.attr('placeholder', '')
      @phoneNumberField.attr('placeholder', '')

    @updateCtcTrigger()

  updateCtcTrigger: ->
    @ctcTrigger.data('ajax-options', { phone: @mobileNumberField.val(), country_name: @countryNameField[0].selectize.items[0] })

  updateCtcTriggerState: =>
    $.get @ctcTrigger.data('verify-url'), (data)=>
      if data.status
        @ctcTrigger.html('Number verified!')
      else
        @ctcTrigger.html('Verify')
