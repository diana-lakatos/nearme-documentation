# Handles the behaviour of entering country+mobile+phone fields
# Used on the user account form, booking modal and the space setup wizard form.
class @DNM.PhoneNumbers

  constructor: (@container, {@countrySelector, @codeSelector, @mobileSelector, @phoneSelector, @sameAsSelector} = {}) ->
    _.defaults @,
      container       : $('div[data-phone-fields-container]')
      countrySelector : 'select[data-country-selector]'
      codeSelector    : '.input-group-addon'
      mobileSelector  : 'input[data-mobile-number]'
      phoneSelector   : 'input[data-phone]'
      sameAsSelector  : 'input[data-same-as-phone-checkbox]'

    return unless @container.length > 0

    @findFields()
    @bindEvents()

    @updateCountryCallingCode()
    @updatePhoneNumber()

  findFields: ->
    @countryNameField  = @container.find(@countrySelector)
    @callingCodeText   = @container.find(@codeSelector)
    @mobileNumberField = @container.find(@mobileSelector)
    @phoneNumberField  = @container.find(@phoneSelector)
    @sameAsPhoneField  = @container.find(@sameAsSelector)

  bindEvents: ->
    @container.on 'change', @countrySelector, ()=>
      @updateCountryCallingCode()

    @container.on 'change keyup', "[type='tel']", ()=>
      @updatePhoneNumber()

    @container.on 'change', @sameAsSelector, ()=>
      @updatePhoneNumber()

  updatePhoneNumber: ->
    @mobileNumberField.prop('readonly', !!@isMobileSameAsPhone())
    @mobileNumberField.val(@phoneNumberField.val()) if @isMobileSameAsPhone()

  isMobileSameAsPhone: ->
    @sameAsPhoneField.is(':checked')

  updateCountryCallingCode: ->
    current = @countryNameField[0].selectize.items[0]
    code = @countryNameField[0].selectize.options[current].callingCode if current

    code = if code
      "+#{code}"
    else
      ""
    @callingCodeText.text(code)

    isDisabled = code is ""

    @mobileNumberField.prop('disabled', isDisabled).closest('.form-group').toggleClass('disabled', isDisabled)
    @phoneNumberField.prop('disabled', isDisabled).closest('.form-group').toggleClass('disabled', isDisabled)


new @DNM.PhoneNumbers()
