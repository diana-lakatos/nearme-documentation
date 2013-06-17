class Users.EditForm

  constructor: (@container) ->
    @countryNameField = @container.find('#user_country_name')
    @callingCodeText = @container.find('.country-calling-code')
    @mobileNumberField = @container.find('#user_mobile_number')

    @bindEvents()
    @updateMobileField()

  bindEvents: ->
    @countryNameField.on 'change', (event) =>
      @updateMobileField()

  updateMobileField: ->
    code = @countryNameField.find('option:selected').data('calling-code')
    code = if code
      "+#{code}"
    else
      ""
    @callingCodeText.text(code)
    @mobileNumberField.prop('disabled', (code is ""))

