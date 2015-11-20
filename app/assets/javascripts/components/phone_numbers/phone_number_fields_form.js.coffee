# Handles the behaviour of entering country+mobile+phone fields
# Used on the user account form, booking modal and the space setup wizard form.
class PhoneNumbers.FieldsForm

  constructor: (@container, {@countrySelector, @codeSelector, @mobileSelector, @phoneSelector, @sameAsSelector} = {}) ->
    _.defaults @,
      container       : $('div[data-phone-fields-container]')
      countrySelector : 'select[data-country-selector]'
      codeSelector    : '.phone-number-country-code-field'
      mobileSelector  : 'input[data-mobile-number]'
      phoneSelector   : 'input[data-phone]'
      sameAsSelector  : 'input[data-same-as-phone-checkbox]'

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
    @countryNameField.on 'change', (event) =>
      @updateCountryCallingCode()

    @phoneNumberField.on 'change', (event) =>
      @updatePhoneNumber()

    @sameAsPhoneField.on 'change', (event) =>
      @updatePhoneNumber()

  updatePhoneNumber: ->
    @mobileNumberField.prop('readonly', !!@isMobileSameAsPhone())
    @mobileNumberField.val(@phoneNumberField.val()) if @isMobileSameAsPhone()

  isMobileSameAsPhone: ->
    @sameAsPhoneField.is(':checked')

  updateCountryCallingCode: ->
    code = @countryNameField.find('option:selected').data('calling-code')
    code = if code
      "+#{code}"
    else
      ""

    if code != ''
      if @callingCodeText.find('.country-calling-code').length > 0
        @callingCodeText.find('.country-calling-code').text(code)
      else
        @callingCodeText.prepend("<div class='country-calling-code'>#{code}</div>")
    else
      @callingCodeText.find('.country-calling-code').remove()

