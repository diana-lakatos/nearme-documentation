module.exports = class InstanceWizardForm
  constructor: (el) ->
    @form = $(el)
    @domainInput = @form.find("input[data-domain-name]")

    @bindEvents()

  bindEvents: ->
    @domainInput.on "input", ->
      value = $(@).val().replace(/[^\w\.\-]/gi, '')
      $(@).val(value.toLowerCase())
