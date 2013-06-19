class Users.EditForm

  constructor: (@container) ->
    @countryNameField = @container.find('#user_country_name')

    # Phone & mobile
    @callingCodeText = @container.find('.country-calling-code')

    @mobileNumberField = @container.find('#user_mobile_number')
    @phoneNumberField = @container.find('#user_phone')

    @sameAsMobileField = @container.find('#user_phone_same_as_mobile')

    @bindEvents()

    @updateCountryCallingCode()
    @updatePhoneNumber()

  bindEvents: ->
    @countryNameField.on 'change', (event) =>
      @updateCountryCallingCode()

    @mobileNumberField.on 'change', (event) =>
      @updatePhoneNumber()

    @sameAsMobileField.on 'change', (event) =>
      @updatePhoneNumber()

  updatePhoneNumber: ->
    @phoneNumberField.prop('readonly', !!@isPhoneSameAsMobile())
    @phoneNumberField.val(@mobileNumberField.val()) if @isPhoneSameAsMobile()

  isPhoneSameAsMobile: ->
    @sameAsMobileField.is(':checked')

  updateCountryCallingCode: ->
    code = @countryNameField.find('option:selected').data('calling-code')
    code = if code
      "+#{code}"
    else
      ""
    @callingCodeText.text(code)
    @mobileNumberField.prop('disabled', (code is ""))
    @phoneNumberField.prop('disabled', (code is ""))

