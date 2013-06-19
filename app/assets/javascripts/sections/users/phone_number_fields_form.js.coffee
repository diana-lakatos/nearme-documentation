# Handles the behaviour of entering country+mobile+phone fields
# Used on the user account form and the space setup wizard form.
class Users.PhoneNumberFieldsForm

  constructor: (@container) ->
    @countryNameField = @container.find('#user_country_name')

    # Phone & mobile
    @callingCodeText = @container.find('.country-calling-code')

    @mobileNumberField = @container.find('#user_mobile_number')
    @phoneNumberField = @container.find('#user_phone')

    @sameAsPhoneField = @container.find('#user_mobile_same_as_phone')

    @bindEvents()

    @updateCountryCallingCode()
    @updatePhoneNumber()

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

