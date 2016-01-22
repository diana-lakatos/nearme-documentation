class @InstanceWizardForm
  constructor: (el)->
    @form = $(el)
    @domainInput = @form.find("input[data-domain-name]")

    @sanitizeDomainInput()

  sanitizeDomainInput: ->
    @domainInput.on "input", ->
      value = $(@).val().replace(/[^\w\.\-]/gi, '')
      $(@).val(value.toLowerCase())

$ ->
  new InstanceWizardForm($('[data-instance-wizard-form]'))
