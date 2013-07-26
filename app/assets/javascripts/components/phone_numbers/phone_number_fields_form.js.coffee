# Handles the behaviour of entering country+mobile+phone fields
# Used on the user account form, booking modal and the space setup wizard form.
class PhoneNumbers.FieldsForm

  constructor: (@container, {@countrySelector, @codeSelector, @mobileSelector, @phoneSelector, @sameAsSelector} = {}) ->
    _.defaults @,
      container       : $('#edit_user')
      countrySelector : '#user_country_name'
      codeSelector    : '.country-calling-code'
      mobileSelector  : '#user_mobile_number'
      phoneSelector   : '#user_phone'
      sameAsSelector  : '#user_mobile_same_as_phone'

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

    @callingCodeText.text(code)
    @mobileNumberField.prop('disabled', (code is ""))
    @phoneNumberField.prop('disabled', (code is ""))

