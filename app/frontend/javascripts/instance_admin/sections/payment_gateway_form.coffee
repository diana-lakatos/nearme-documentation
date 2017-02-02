module.exports = class InstanceAdminPaymentGatewayForm
  constructor: (form) ->
    @form = form
    @bindevents()

  bindevents: ->
    @configSetup()
    @form.find("[data-interval]").on 'change', (event) =>
      @configSetup()

  configSetup: ->
    form = @form
    @form.find("[data-show-if]").each ->
      field_data = '[data-' + $(this).attr('data-show-if').split('-')[0] + "]"
      field_value = $(this).attr('data-show-if').split('-')[1]
      field = form.find(field_data)
      if field.val() == field_value
        $(this).parents('.input-container').show()
        $(this).prop('disabled', false)
      else
        $(this).parents('.input-container').hide()
        $(this).prop('disabled', true)
      return
